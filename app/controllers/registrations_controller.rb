class RegistrationsController < ApplicationController
  before_action :doorkeeper_authorize!, except: [:create, :oauth]

  def create
    user = User.new(sign_up_params)

    if user.save
      token = Doorkeeper::AccessToken.create!(:application_id => ENV['APPLICATION_ID'],
                                              :resource_owner_id => user.id)

      render json: { access_token: token.token }
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

  def oauth
    user = User.where(sign_up_params).first

    unless user
      user = User.new(sign_up_params)
      user.save(:validate => false)
    end

    token = Doorkeeper::AccessToken.create!(:application_id => ENV['APPLICATION_ID'],
                                            :resource_owner_id => user.id)
    render json: { access_token: token.token }
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :uid)
  end
end