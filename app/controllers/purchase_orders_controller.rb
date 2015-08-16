class PurchaseOrdersController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    @purchase_orders = current_user.purchase_orders

    respond_with @purchase_orders.includes(:code)
  end

  def show
    @code = Code.find(params[:id])

    respond_with @code
  end
end