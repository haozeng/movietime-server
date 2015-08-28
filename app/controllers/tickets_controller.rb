class TicketsController < ApplicationController
  before_action :doorkeeper_authorize!, except: :create
  skip_authorization_check only: :create
  skip_load_and_authorize_resource only: :create

  # http basic auth for codes creation
  http_basic_authenticate_with name: ENV['TICKET_CREATION_USERNAME'], password: ENV['TICKET_CREATION_PASSWORD'], only: :create

  # End point for scanner
  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      respond_with @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: 422
    end
  end

  def show
    @ticket = Ticket.find(params[:id])

    respond_with @ticket
  end

  def mark_used
    @ticket = Ticket.find(params[:id])
    @ticket.mark_used!

    head :ok
  end

  def mark_unused
    @ticket = Ticket.find(params[:id])
    @ticket.mark_unused!

    head :ok
  end

  private
  def ticket_params
     params.require(:ticket).permit(:code, :brand_id)
  end
end