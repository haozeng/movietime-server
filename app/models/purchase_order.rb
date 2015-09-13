class PurchaseOrder < ActiveRecord::Base
  has_many :tickets
  belongs_to :user

  attr_accessor :payment_profile_id, :number_of_tickets, :brand_id

  def purchase_in_stripe(params)
    payment_profile_id = params[:payment_profile_id]
    number_of_tickets = params[:number_of_tickets].to_i
    brand_id = params[:brand_id]
    price = number_of_tickets * Brand.find(brand_id).price

    begin
      stripe_user_id = PaymentProfile.find(payment_profile_id).stripe_user_id
      charge = Stripe::Charge.create(
        amount: (price*100).to_i, # amount in cents, again
        currency: "usd",
        customer: stripe_user_id
      )

      generate_tickets(number_of_tickets, brand_id)
      update_attributes(price: price)
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