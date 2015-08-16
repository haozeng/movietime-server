require 'rails_helper'

describe PurchaseOrdersController do
  render_views
  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)

    purchase_order = create :purchase_order, user: user
    create_list :code, 3, purchase_order: purchase_order
  end

  context "#index" do
    it 'should return a list of purchase_orders for user' do
      get :index, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['purchase_orders'].count).to eql(3)
    end
  end

  context "#index" do
    it 'should return one code for user' do
      get :show, id: Code.last.id, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result).to include('brand', 'logo', 'code')
    end
  end
end