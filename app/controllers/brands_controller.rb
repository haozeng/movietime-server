class BrandsController < ApplicationController
  respond_to :json

  def index
    @brands = Brand.all

    respond_with @brands
  end
end