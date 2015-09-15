class BrandsController < ApplicationController
  skip_before_action :doorkeeper_authorize!
  skip_authorization_check
  skip_load_and_authorize_resource

  def index
    @brands = Brand.all

    respond_with @brands
  end

  def show
    @brand = Brand.find_by_id(params[:id])

    respond_with @brand
  end
end