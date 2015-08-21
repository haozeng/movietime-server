require "application_responder"

class ApplicationController < ActionController::Base
  load_and_authorize_resource
  check_authorization

  self.responder = ApplicationResponder
  respond_to :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token  

  def current_user
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end