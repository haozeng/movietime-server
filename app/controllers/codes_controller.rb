class CodesController < ApplicationController
  before_action :doorkeeper_authorize!

  def show
    @code = Code.find(params[:id])

    respond_with @code
  end

  def mark_used
    @code = Code.find(params[:id])
    @code.mark_used!

    head :ok
  end

  def mark_unused
    @code = Code.find(params[:id])
    @code.mark_unused!

    head :ok
  end
end