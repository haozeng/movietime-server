require 'rails_helper'

describe PaymentProfilesController do
  render_views

  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
    allow_any_instance_of(PaymentProfile).to receive(:create_in_stripe).and_return(true)
    allow_any_instance_of(PaymentProfile).to receive(:destroy_in_stripe).and_return(true)
  end

  context "#create" do
    it "should create a paymenet profile" do
      post :create, payment_profile: { user_id: user.id, brand: 'MC',
                                       last_four_digits: '4212' },
                    format: :json

      expect(response.status).to eql(200)
      expect(user.payment_profiles.count).to eql(1)
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
      expect(result).to include('user_id', 'id', 'brand', 'last_four_digits')
    end
  end

  context "#destroy" do
    before do
      create :payment_profile, user: user, stripe_user_id: '1234'
    end

    it "should the payment_profile for this user" do
      delete :destroy, id: PaymentProfile.last.id, format: :json

      expect(response.status).to eql(204)
      expect(user.payment_profiles.count).to eql(0)
    end
  end
end