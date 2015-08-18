class PaymentProfile < ActiveRecord::Base
  belongs_to :user

  def create_in_stripe(stripe_token)
    stripe_user = Stripe::Customer.create(source: stripe_token, description: "server user id: #{user.id}")
    self.stripe_user_id = stripe_user.id
    save!
  end
end