class TicketsController < ApplicationController
  before_action :doorkeeper_authorize!

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
end