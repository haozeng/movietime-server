class PaymentProfilesController < ApplicationController
  def create
    @payment_profile = PaymentProfile.new(payment_profile_params)

    if @payment_profile.save
      @payment_profile.create_in_stripe(payment_profile_params[:stripe_token])
      respond_with @payment_profile
    else
      render json: { errors: @payment_profile.errors.full_messages }, status: 422
    end
  end

  def show
    @payment_profile = PaymentProfile.find(params[:id])
    respond_with @payment_profile
  end

  def index
    @payment_profiles = current_user.payment_profiles.order('created_at DESC')
    respond_with @payment_profiles
  end

  def update
    @payment_profile = PaymentProfile.find(params[:id])

    if @payment_profile.update_attributes(payment_profile_params)
      respond_with @payment_profile
    else
      render json: { errors: @payment_profile.errors.full_messages }, status: 422
    end
  end

  def destroy
    @payment_profile = PaymentProfile.find(params[:id])
    @payment_profile.destroy

    head 204
  end

  private

  def payment_profile_params
    params.require(:payment_profile).permit(:card_type, :last_four_digits, :user_id, :stripe_token, :default, :exp)
  end
end