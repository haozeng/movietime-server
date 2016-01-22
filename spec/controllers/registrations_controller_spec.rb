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

    it 'user using facebook in the past should still be able to sign up using regular flow' do
      create :user, uid: 'facebook_uid', email: 'facebook@gmail.com'

      post :create, user: { email: 'facebook@gmail.com', password: '12345678', password_confirmation: '12345678' },
           format: :json

      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['access_token']).not_to be_nil
    end

    it 'sign up with the previous ios_id' do
      user = User.new(ios_id: 'ios_id')
      user.save(:validate => false)

      post :create, user: { ios_id: 'ios_id', email: 'user@gmail.com', password: '12345678', password_confirmation: '12345678' },
           format: :json

      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['access_token']).not_to be_nil
      expect(User.count).to eql(1)
      expect(User.last.email).to eql('user@gmail.com') 
    end
  end

  context "#temp" do
    it 'should create a new user with ios_id, and returns an access_token' do
      post :temp, user: { ios_id: 'ios_id' },
           format: :json

      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['access_token']).not_to be_nil
      expect(result['user_id']).not_to be_nil
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
        user = User.new(uid: 'facebook_uid', email: 'facebook@gmail.com', password: nil, password_confirmation: nil)
        user.save(:validate => false)
      end

      it 'should be able to create a user from facebook oauth info' do
        post :oauth, user: { uid: '1234567', email: 'test@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
        expect(User.last.uid).not_to be_nil
        expect(User.last.encrypted_password).not_to eql("")
      end

      it 'should not require password for the same facebook login user as long as email matches' do
        post :oauth, user: { uid: 'facebook_uid', email: 'facebook@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
      end

      it 'should ask the user to reset the password if it was usig regular login' do
        post :oauth, user: { email: 'facebook@gmail.com', password: '123456' }
        expect(response.status).to eql(422)
        result = JSON.parse(response.body)
        expect(result["errors"]).to match(/It looks like you already have an account with us. If you forget your password, please reset your password./)
      end

      it 'sign up with facebook with previous ios_id' do
        user = User.new(ios_id: 'ios_id')
        user.save(:validate => false)

        post :oauth, user: { uid: '1234567', email: 'test@gmail.com', ios_id: 'ios_id' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
        expect(User.last.uid).not_to be_nil
        expect(User.last.encrypted_password).not_to eql("")
      end

      it 'sign in if the previous sign up was using ios_id with facebook uid too' do
        user = User.new(uid: 'facebook_uid', email: 'facebook2@gmail.com', password: nil, password_confirmation: nil,
                        ios_id: 'ios_id')
        user.save(:validate => false)

        post :oauth, user: { uid: 'facebook_uid', email: 'facebook2@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
      end
    end

    context "#regular user" do
      before do
        create :user, email: 'regular@gmail.com', password: '123456'
      end

      it 'should be able to login the user using the right password' do
        post :oauth, user: { email: 'regular_not_exist@gmail.com' }
        expect(response.status).to eql(422)
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

      it 'should be able to login using facebook account and match with the same email' do
        post :oauth, user: { uid: '1234567', email: 'regular@gmail.com' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
        expect(User.last.uid).not_to be_nil
      end

      it 'sign in if the previous sign up was using ios_id' do
        create :user, email: 'regular-ios@gmail.com', password: '123456', ios_id: 'ios_id'

        post :oauth, user: { email: 'regular-ios@gmail.com', password: '123456' }
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['access_token']).not_to be_nil
      end
    end
  end
end