class HomeController < ApplicationController
  skip_authorization_check
  skip_load_and_authorize_resource

  respond_to :html

  def index
  end
end