require 'rails_helper'

describe PurchaseOrdersController do
  render_views
  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }
  let(:payment_profile) { create :payment_profile, user: user }
  let(:brand) { create :brand }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  context "#index" do
    before do
      purchase_order = create :purchase_order, user: user
      codes = create_list :code, 4, purchase_order: purchase_order
      @one = codes[0]

      purchase_order_two = create :purchase_order, user: user, created_at: 1.day.ago
      @two = create :code, purchase_order: purchase_order_two
    end

    it 'should return a list of purchase_orders for user' do
      get :index, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['purchase_orders'].count).to eql(5)
    end

    context "pagination" do
      before do
        purchase_order = create :purchase_order, user: user
        codes = create_list :code, 40, purchase_order: purchase_order
      end

      it "should return 20 results at once" do
        get :index, page: 1, format: :json
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)
        expect(result['purchase_orders'].count).to eql(20)
      end
    end

    context "used and unused sorting" do
      before do
        @one.mark_used!
      end

      it 'should return codes in the order of unused first, and then used' do
        get :index, format: :json
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)['purchase_orders']
        expect(result[-1]['code']).to eql(@one.code)
        expect(result[-2]['code']).to eql(@two.code)
      end
    end
  end

  context "#create" do
    before do
      allow(Stripe::Charge).to receive(:create).and_return(true)
    end

    it 'should return one code for user' do
      post :create, purchase_order: { brand_id: brand.id, payment_profile_id: payment_profile.id,
                                      price: brand.price*2, number_of_codes: 2 }, format: :json
      expect(response.status).to eql(200)
      expect(user.purchase_orders.count).to eql(1)
      expect(user.purchase_orders[0].codes.count).to eql(2)
    end
  end
end