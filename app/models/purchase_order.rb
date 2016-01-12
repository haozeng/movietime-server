class PurchaseOrder < ActiveRecord::Base
  has_many :tickets
  belongs_to :user

  attr_accessor :payment_profile_id, :number_of_tickets, :brand_id

  def purchase_in_stripe(params)
    payment_profile_id = params[:payment_profile_id]
    number_of_tickets = params[:number_of_tickets].to_i
    brand_id = params[:brand_id]
    price = number_of_tickets * Brand.find(brand_id).price

    unless enough_tickets?(brand_id, params[:number_of_tickets])
      self.errors.add(:base, "We are experiencing ticketing issue. You card wasn't charged. Please try again later.")
      return false
    end

    begin
      stripe_user_id = PaymentProfile.find(payment_profile_id).stripe_user_id
      charge = Stripe::Charge.create(
        amount: (price*100).to_i, # amount in cents, again
        currency: "usd",
        customer: stripe_user_id
      )

      ## save the purchase order before generating the ticket
      update_attributes(price: price)

      ## generate the tickets
      generate_tickets(number_of_tickets, brand_id)
    rescue Stripe::CardError => e
      # Since it's a decline, Stripe::CardError will be caught
      puts "Code is: #{e.code}"
      puts "Param is: #{e.param}"
      puts "Message is: #{e.message}"
      self.errors.add(:base, "#{e.message} Please try a different card.")

      false
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

  def enough_tickets?(brand_id, number_of_tickets)
    Ticket.where(brand_id: brand_id, purchase_order_id: nil).size >= number_of_tickets
  end
end