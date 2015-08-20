require 'rails_helper'

describe CodesController do
  render_views

  let!(:user) { create :user }
  let(:token) { double :acceptable? => true, :resource_owner_id => user.id }
  let(:payment_profile) { create :payment_profile, user: user }
  let(:brand) { create :brand }

  before do
    allow(controller).to receive(:doorkeeper_token).and_return(token)
  end

  context "#mark_use" do
    before do
      purchase_order = create :purchase_order, user: user
      @code = create :code, purchase_order: purchase_order
    end

    it 'should mark the code as used' do
      post :mark_used, id: @code.id
      expect(response.status).to eql(200)
      expect(Code.last.used?).to be true
    end
  end
end