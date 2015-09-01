class PurchaseOrdersController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    # use params[:page] and params[:per_page] to paginate
    @tickets = paginate Ticket.joins(:purchase_order => :user).
                               where('purchase_orders.user_id = ?', current_user.id).
                               order(:status).order('purchase_orders.created_at DESC'), per_page: 20

    respond_with @tickets
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
                                           :number_of_tickets, :brand_id)
  end
end