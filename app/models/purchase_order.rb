class PurchaseOrder < ActiveRecord::Base
  has_many :tickets
  belongs_to :user

  attr_accessor :payment_profile_id, :number_of_tickets, :brand_id

  def purchase_in_stripe(params)
    payment_profile_id = params[:payment_profile_id]
    price = params[:price]
    number_of_tickets = params[:number_of_tickets]
    brand_id = params[:brand_id]

    begin
      stripe_user_id = PaymentProfile.find(payment_profile_id).stripe_user_id
      charge = Stripe::Charge.create(
        amount: price*100, # amount in cents, again
        currency: "usd",
        stripe_user_id: stripe_user_id
      )

      generate_tickets(number_of_tickets, brand_id)
    rescue Stripe::CardError => e
      # The card has been declined
    end
  end

  def generate_tickets(number_of_tickets, brand_id)
    number_of_tickets.times do
      ticket = Ticket.where(brand_id: brand_id, purchase_order_id: nil).first
      if ticket
        ticket.update_attributes(purchase_order_id: self.id)
      else
        raise 'Please load tickets into the database'
      end
    end
  end
end