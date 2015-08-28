class PaymentProfile < ActiveRecord::Base
  belongs_to :user

  before_destroy :destroy_in_stripe

  attr_accessor :stripe_token

  def create_in_stripe(stripe_token)
    stripe_user = Stripe::Customer.create(source: stripe_token, description: "server user id: #{user.id}")
    self.stripe_user_id = stripe_user.id
    save!
  end

  private

  def destroy_in_stripe
    u = Stripe::Customer.retrieve(stripe_user_id)
    u.delete
  end
end