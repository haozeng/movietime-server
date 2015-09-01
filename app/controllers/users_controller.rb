class UsersController < ApplicationController
  before_action :doorkeeper_authorize!
  skip_load_and_authorize_resource
  load_and_authorize_resource :ticket, :class => 'Ticket'

  def show
    @user = current_user    
    @payment_profiles = current_user.payment_profiles
    # return 40 tickets
    @tickets = paginate Ticket.joins(:purchase_order => :user).
                               where('purchase_orders.user_id = ?', current_user.id).
                               order(:status).order('purchase_orders.created_at DESC'), per_page: 40

    response = { user: @user, 
                 payment_profiles: @payment_profiles, 
                 tickets: @tickets }                             
    respond_with response
  end
end