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

    it "should send back error message if user email doesn't exist" do
      post :create, user: { email: 'no_existing_email@gmail.com' }, format: :json
      expect(response.status).to eql(422)
      result = JSON.parse(response.body)
      expect(result['errors']).to eql("The user email doesn't exist.")
    end
  end
end