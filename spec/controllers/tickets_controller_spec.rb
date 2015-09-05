require 'rails_helper'

describe TicketsController do
  render_views

  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }
  let(:payment_profile) { create :payment_profile, user: user }
  let(:brand) { create :brand }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  context "#create" do
    let(:code) { rand.to_s[2..1] }

    before do
      @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("#{ENV['TICKET_CREATION_USERNAME']}:#{ENV['TICKET_CREATION_PASSWORD']}")
    end

    it "should create a code from scanner" do
      post :create, ticket: { code: code, brand_id: brand.id }, format: :json
      expect(response.status).to eql(200)
      expect(Ticket.last.code).to eql(code)
    end

    it "same code shall not be allowed" do
      ticket = create :ticket

      post :create, ticket: { code: ticket.code }, format: :json
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result["errors"]).to eql(['Code has already been taken'])
    end
  end

  context "#mark_use" do
    before do
      purchase_order = create :purchase_order, user: user
      @ticket = create :ticket, purchase_order: purchase_order
    end

    it 'should mark the ticket as used' do
      post :mark_used, id: @ticket.id, format: :json
      expect(response.status).to eql(200)
      expect(Ticket.last.used?).to be true
    end

    let(:other_purchase_order) { create :purchase_order }
    let(:other_ticket) { create :ticket, purchase_order: other_purchase_order }
    it "should not mark ticket other than his own" do
      post :mark_used, id: other_ticket.id, format: :json
      expect(response.status).to eql(401)
    end
  end
end