class PurchaseOrder < ActiveRecord::Base
  has_many :codes
  belongs_to :user

  def purchase_in_stripe(params)
    payment_profile_id = params[:payment_profile_id]
    price = params[:price]
    number_of_codes = params[:number_of_codes]
    brand_id = params[:brand_id]

    begin
      stripe_user_id = PaymentProfile.find(payment_profile_id).stripe_user_id
      charge = Stripe::Charge.create(
        amount: price*100, # amount in cents, again
        currency: "usd",
        stripe_user_id: stripe_user_id
      )

      generate_codes(number_of_codes, brand_id)
    rescue Stripe::CardError => e
      # The card has been declined
    end
  end

  def generate_codes(number_of_codes, brand_id)
    number_of_codes.times do
      Code.create(purchase_order_id: self.id,
                  brand_id: brand_id)
    end
  end
end