class RegistrationsController < ApplicationController
  before_action :doorkeeper_authorize!, except: :create

  def create
    user = User.new(sign_up_params)

    if user.save
      head :ok
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end
  end

  def update
    user = User.find(params[:id])

    if user.update_attributes(sign_up_params)
      head :ok
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end 
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end