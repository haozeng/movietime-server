require "application_responder"

class ApplicationController < ActionController::Base
  before_action :doorkeeper_authorize!
  load_and_authorize_resource
  check_authorization

  self.responder = ApplicationResponder
  respond_to :json

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :verify_authenticity_token  

  rescue_from CanCan::AccessDenied do |exception|
    head 401
  end

  def current_user
    User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end