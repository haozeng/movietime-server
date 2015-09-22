require 'rails_helper'

describe PaymentProfilesController do
  render_views

  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
    allow(Stripe::Customer).to receive(:create).and_return(double('stripe_user', id: '123124sadf'))
    allow(Stripe::Customer).to receive(:retrieve).and_return(double('stripe_user', delete: true))
  end

  context "#create" do
    it "should create a paymenet profile" do
      post :create, payment_profile: { user_id: user.id, card_type: 'MC',
                                       last_four_digits: '4212' },
                    format: :json

      expect(response.status).to eql(200)
      expect(user.payment_profiles.count).to eql(1)
      expect(user.payment_profiles[0].default).to be true
    end

    it 'if purchase is declined, respond with error message and purchase order should not be saved' do
      allow(Stripe::Customer).to receive(:create).and_raise(Stripe::CardError.new('Your card is declined', {},'card_declined'))
      post :create, payment_profile: { user_id: user.id, card_type: 'MC',
                                       last_four_digits: '4212' },
                    format: :json

      expect(response.status).to eql(422)
      expect(user.payment_profiles.count).to eql(0)
      result = JSON.parse(response.body)
      expect(result["errors"][0]).to match(/Your card is declined/)
    end

    it 'if user add second payment_profile, the first default one should be revoked' do
      post :create, payment_profile: { user_id: user.id, card_type: 'MC',
                                       last_four_digits: '4321' },
                    format: :json

      expect(user.payment_profiles[0].default).to be true

      post :create, payment_profile: { user_id: user.id, card_type: 'MC',
                                       last_four_digits: '1234' },
                    format: :json

      expect(user.payment_profiles.where(last_four_digits: '4321').first.default).to be false
      expect(user.payment_profiles.where(last_four_digits: '1234').first.default).to be true
    end
  end

  context "#index" do
    before do
      create_list :payment_profile, 3, user: user 
    end

    it "should return all payment profiles for this user" do
      get :index, format: :json

      expect(response.status).to eql(200)
      expect(user.payment_profiles.count).to eql(3)
    end
  end

  context "#show" do
    before do
      create :payment_profile, user: user 
    end

    it "should return all payment profiles for this user" do
      get :show, id: PaymentProfile.last.id, format: :json

      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result).to include('user_id', 'id', 'card_type', 'last_four_digits')
    end

    let(:other_payment_profile) { create :payment_profile }
    it "should not see payment profiles other than his own" do
      get :show, id: other_payment_profile.id, format: :json
      expect(response.status).to eql(401)
    end
  end

  context "#destroy" do
    before do
      @payment_profile = create :payment_profile, user: user, stripe_user_id: '1234', default: true
    end

    it "should the payment_profile for this user" do
      delete :destroy, id: PaymentProfile.last.id, format: :json

      expect(response.status).to eql(204)
      expect(user.payment_profiles.count).to eql(0)
    end

    let(:other_payment_profile) { create :payment_profile }
    it "should not destroy payment profiles other than his own" do
      delete :destroy, id: other_payment_profile.id, format: :json
      expect(response.status).to eql(401)
    end

    it "if default payment_profile is destroyed, choose the next one to be default" do
      next_payment_profile = create :payment_profile, user: user, stripe_user_id: '1234'

      delete :destroy, id: @payment_profile.id, format: :json

      expect(response.status).to eql(204)
      expect(next_payment_profile.reload.default).to be true
    end

    it "if not the default payment_profile is destroyed, then default payment_profile should not be changed" do
      next_payment_profile = create :payment_profile, user: user, stripe_user_id: '1234'

      delete :destroy, id: next_payment_profile.id, format: :json

      expect(response.status).to eql(204)
      expect(@payment_profile.reload.default).to be true
    end

    it 'if destroy payment_profile is declined, alert admin about the reason' do
    end
  end

  context "#update" do
    before do
      create :payment_profile, user: user, stripe_user_id: '1234'
    end

    it "should set the default payment_profile for this user" do
      put :update, id: PaymentProfile.last.id, payment_profile: { default: true }, format: :json

      expect(response.status).to eql(200)
      expect(PaymentProfile.last.default).to be true
    end

    let(:other_payment_profile) { create :payment_profile }
    it "should not set payment profiles other than his own" do
      put :update, id: other_payment_profile.id, payment_profile: { default: true }, format: :json

      expect(response.status).to eql(401)
    end
  end
end