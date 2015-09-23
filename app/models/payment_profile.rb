class PaymentProfile < ActiveRecord::Base
  belongs_to :user

  before_destroy :destroy_in_stripe

  attr_accessor :stripe_token
  validates :last_four_digits, uniqueness: { scope: [:user_id, :card_type], message: '^Credit Card already exists.' }

  def set_default
    update_attributes(default: true)
  end

  def unset_default
    update_attributes(default: false)
  end

  def create_in_stripe(stripe_token)
    begin
      return false unless valid?
      stripe_user = Stripe::Customer.create(source: stripe_token, description: "server user id: #{user.id}")

      self.stripe_user_id = stripe_user.id
      self.default = true
      user.unset_default_payment_profile
      save
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      puts "Code is: #{e.code}"
      puts "Param is: #{e.param}"
      puts "Message is: #{e.message}"
      self.errors.add(:base, "#{e.message}. Please try a different card.")

      false
    end
  end

  private

  def destroy_in_stripe
    begin
      u = Stripe::Customer.retrieve(stripe_user_id)
      u.delete

      set_default_payment_profile
    rescue Stripe::InvalidRequestError => e
      # Since it's a decline, Stripe::CardError will be caught
      puts "error: #{e.inspect}"
      # alert admin why the card can not be destroyed
      # TODO:
    end
  end

  def set_default_payment_profile
    if default
      payment_profiles = user.payment_profiles.where.not(id: id)
      if payment_profiles.count > 0
        payment_profiles[0].set_default
      end
    end
  end
end