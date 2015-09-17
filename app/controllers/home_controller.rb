class HomeController < ApplicationController
  skip_before_action :doorkeeper_authorize!
  skip_authorization_check
  skip_load_and_authorize_resource

  respond_to :html

  def index
  end
end