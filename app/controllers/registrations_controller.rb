class RegistrationsController < ApplicationController
  skip_before_action :doorkeeper_authorize!, except: [:update]
  skip_authorization_check
  skip_load_and_authorize_resource

  def create
    user = User.new(sign_up_params)

    if user.save
      token = Doorkeeper::AccessToken.create!(application_id: ENV['APPLICATION_ID'],
                                              resource_owner_id: user.id,
                                              expires_in: Doorkeeper.configuration.access_token_expires_in)

      render json: { access_token: token.token, user_id: user.id }
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end
  end

  def update
    user = current_user

    if user.update_attributes(sign_up_params)
      head :ok
    else
      render json: { errors: user.errors.full_messages }, status: 422
    end 
  end

  def oauth
    user = User.where(sign_up_params.slice(:email)).first

    if sign_up_params[:uid].blank?
      unless user
        render json: { errors: 'The email does not exist in our system.' }, status: 422 and return
      end

      unless user.valid_password?(sign_up_params[:password])
        render json: { errors: 'The password you entered is not correct.' }, status: 422 and return
      end
    else # Facebook sign up/sign in
      if user
        if user.uid != sign_up_params[:uid]
          render json: { errors: 'Invalid Sign in with facebook. User ID doesn\'t match. Please contact support.' }, status: 422 and return
        end
      else
        user = User.new(sign_up_params)
        user.save(:validate => false)
      end
    end

    token = Doorkeeper::AccessToken.create!(application_id: ENV['APPLICATION_ID'],
                                            resource_owner_id: user.id,
                                            expires_in: Doorkeeper.configuration.access_token_expires_in)
    render json: { access_token: token.token, user_id: user.id }
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :uid)
  end
end