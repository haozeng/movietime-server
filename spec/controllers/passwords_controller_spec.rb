require 'rails_helper'

describe PasswordsController do
  render_views

  let(:user) { create :user }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "#create" do
    it "should reset the user password" do
      post :create, user: { email: user.email }, format: :json
      expect(response.status).to eql(201)
      expect(ActionMailer::Base.deliveries.size).to eql(1)
    end
  end
end