require 'rails_helper'

describe RegistrationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "#create" do
    it 'should register a new user with email and password, and returns an access_token' do
      post :create, user: { email: 'user@gmail.com', password: '12345678', password_confirmation: '12345678' },
           format: :json

      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['access_token']).not_to be_nil
    end

    it 'should not create a user if password does not match' do
      post :create, user: { email: 'user@gmail.com', password: '12345678', password_confirmation: '123456' },
           format: :json

      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["errors"][0]).to match(/Password confirmation doesn't match Password/)
    end
  end

  context "#update" do
    let!(:user) { create :user }
    let(:token) { double :acceptable? => true, :resource_owner_id => user.id }

    before do
      allow(controller).to receive(:doorkeeper_token).and_return(token)
    end

    it 'should be able to update user information' do
      put :update, id: user, user: { password: 'abcedf', password_confirmation: 'abcedf' }
      expect(response.status).to eql(200)
      expect(user.reload.valid_password?('abcedf')).to be true
    end
  end

  context "#oauth" do
    context "#facebook" do
      before do
        create :user, uid: 'facebook_uid', email: 'facebook@gmail.com'
      end

      it 'should be able to create a user from facebook oauth info' do
        post :oauth, user: { uid: '1234567', email: 'test@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
        expect(User.last.uid).not_to be_nil
      end

      it 'should not require password for the same facebook login user as long as uid matches' do
        post :oauth, user: { uid: 'facebook_uid', email: 'facebook@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
      end

      it 'should render 422 if the facebook uid doesn\'t match' do
        post :oauth, user: { uid: 'facebook_uid_not_match', email: 'facebook@gmail.com' }
        expect(response.status).to eql(422)
      end
    end

    context "#regular user" do
      before do
        create :user, email: 'regular@gmail.com', password: '123456'
      end

      it 'should be able to login the user using the right password' do
        post :oauth, user: { email: 'regular@gmail.com', password: '123456' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
      end

      it 'should render 422 if the password doesn\'t match' do
        post :oauth, user: { email: 'regular@gmail.com', password: '12345678' }
        expect(response.status).to eql(422)
      end
    end
  end
end