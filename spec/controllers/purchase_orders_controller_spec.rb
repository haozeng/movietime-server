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
      tickets = create_list :ticket, 4, purchase_order: purchase_order
      @one = tickets[0]

      purchase_order_two = create :purchase_order, user: user, created_at: 1.day.ago
      @two = create :ticket, purchase_order: purchase_order_two
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
        tickets = create_list :ticket, 40, purchase_order: purchase_order
      end

      it "should return all results at once" do
        get :index, format: :json
        expect(response.status).to eql(200)
      end
    end

    context "used and unused sorting" do
      before do
        @one.mark_used!
      end

      it 'should return tickets in the order of unused first, and then used' do
        get :index, format: :json
        expect(response.status).to eql(200)
        result = JSON.parse(response.body)['purchase_orders']
        expect(result[-1]['code']).to eql(@one.code)
        expect(result[-2]['code']).to eql(@two.code)
      end
    end
  end

  context "#purchase_order_index" do
    before do
      purchase_order = create :purchase_order, user: user
      tickets = create_list :ticket, 4, purchase_order: purchase_order
      @one = tickets[0]

      purchase_order_two = create :purchase_order, user: user, created_at: 1.day.ago
      @two = create :ticket, purchase_order: purchase_order_two
    end

    it 'should return a list of purchase_orders for user' do
      get :purchase_orders_index, format: :json
      expect(response.status).to eql(200)
      result = JSON.parse(response.body)
      expect(result['purchase_orders'].count).to eql(2)
      expect(result['purchase_orders'][0]['tickets'].count).to eql(4)
    end
  end

  context "#create" do
    context "successful transaction" do
      before do
        allow(Stripe::Charge).to receive(:create).and_return(true)
        create_list :ticket, 2, brand_id: brand.id
      end

      it 'should return one ticket for user' do
        post :create, purchase_order: { brand_id: brand.id, payment_profile_id: payment_profile.id,
                                        number_of_tickets: 2 }, format: :json
        expect(response.status).to eql(200)
        expect(user.purchase_orders.count).to eql(1)
        expect(user.purchase_orders[0].tickets.count).to eql(2)
        expect(user.purchase_orders[0].price).to eql(brand.price * 2)
        expect(Ticket.last.purchase_order_id).to eql(user.purchase_orders[0].id)
      end
    end

    context "unsucessfuly transaction" do
      before do
        allow(Stripe::Charge).to receive(:create).and_raise(Stripe::CardError.new('Your card is declined', {}, 'card_declined'))
        create_list :ticket, 2, brand_id: brand.id
      end

      it 'if purchase is declined, respond with error message and purchase order should not be saved' do
        post :create, purchase_order: { brand_id: brand.id, payment_profile_id: payment_profile.id,
                                        number_of_tickets: 2 }, format: :json

        expect(response.status).to eql(422)
        expect(user.purchase_orders.count).to eql(0)
        result = JSON.parse(response.body)
        expect(result["errors"][0]).to match(/Your card is declined/)
      end
    end

    context "tickets running out" do
      before do
        Ticket.destroy_all
      end

      it 'if tickets are running out, respond with error message and purchase order should not be saved' do
        post :create, purchase_order: { brand_id: brand.id, payment_profile_id: payment_profile.id,
                                        number_of_tickets: '1' }, format: :json

        expect(response.status).to eql(422)
        expect(user.purchase_orders.count).to eql(0)
        result = JSON.parse(response.body)
        expect(result["errors"][0]).to match(/We are experiencing ticketing issue. You card wasn't charged. Please try again later./)
      end
    end
  end
end