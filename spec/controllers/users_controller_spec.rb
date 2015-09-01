require 'rails_helper'

describe UsersController do
  render_views
  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  context "#index" do
    before do
      purchase_order = create :purchase_order, user: user
      create_list :ticket, 4, purchase_order: purchase_order
      create_list :payment_profile, 3, user: user
    end

    it 'should return all user related data' do
      get :show, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result).to include('user', 'purchase_orders', 'payment_profiles')
    end
  end
end