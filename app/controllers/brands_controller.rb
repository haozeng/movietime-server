class BrandsController < ApplicationController
  def index
    @brands = Brand.all

    respond_with @brands
  end

  def show
    @brand = Brand.find_by_id(params[:id])

    respond_with @brand
  end
end