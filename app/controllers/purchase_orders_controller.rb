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

  def create
    @purchase_order = current_user.purchase_orders.new(purchase_order_params.slice(:price))

    if @purchase_order.save
      @purchase_order.purchase_in_stripe(purchase_order_params)
      respond_with @purchase_order
    else
      render json: { errors: @purchase_order.errors.full_messages }, status: 422
    end
  end

  private
  def purchase_order_params
    params.require(:purchase_order).permit(:payment_profile_id, :price,
                                           :number_of_codes, :brand_id)
  end
end