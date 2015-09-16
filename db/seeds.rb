Doorkeeper::Application.find_or_create_by(:name => 'MovieTime', :redirect_uri => 'http://movietime.com/callback')

def ensure_brand(brand_params)
  brand = Brand.where(name: brand_params[:name]).first || Brand.new
  brand.update_attributes(brand_params)
  brand
end

def ensure_user(user_params)
  user = User.where(email: user_params[:email]).first || User.new
  user.update_attributes(user_params)
  user
end

def ensure_payment_profile(user, payment_profile_params)
  payment_profile = user.payment_profiles.where(card_type: payment_profile_params[:card_type], last_four_digits: payment_profile_params[:last_four_digits]).first || user.payment_profiles.new
  payment_profile.update_attributes(payment_profile_params)
  payment_profile
end

def ensure_ticket(brand, ticket_params)
  ticket = brand.tickets.where(code: ticket_params[:code]).first || brand.tickets.new
  ticket.update_attributes(ticket_params)
  ticket
end

def ensure_purchase_order(user, purchase_order_params)
  purchase_order = user.purchase_orders.new
  purchase_order.update_attributes(purchase_order_params)
  purchase_order
end

if Rails.env.development?
  amc = ensure_brand(name: 'amc', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'amc.png'), 'r'), description: 'Available at at any AMC®, AMC Showplace, Loews®, Cineplex Odeon, Magic Johnson and Star theatres.', title: 'AMC Green E-Ticket')
  regal = ensure_brand(name: 'regal', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'regal.png'), 'r'), description: 'Available at any Regal Cinemas®, Edwards® Theatres, United Artists Theatres and Hollywood Theaters.', title: 'Regal Premiere E-Ticket')
  cinemark = ensure_brand(name: 'cinemark', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'cinemark.png'), 'r'), description: 'Available at any Cinemark Theatre nationwide.', title: 'Cinemark Platinum E-Ticket')

  user = ensure_user(email: 'hzeng1989@gmail.com', password: '123456', password_confirmation: '123456',
                     first_name: 'hao', last_name: 'zeng')
  user2 = ensure_user(email: 'daceywang@gmail.com', password: '123456', password_confirmation: '123456',
                     first_name: 'yefei', last_name: 'wang')

  payment_profile = ensure_payment_profile(user, { card_type: 'MC', last_four_digits: '3212', stripe_user_id: '1' })
  payment_profile = ensure_payment_profile(user2, { card_type: 'MC', last_four_digits: '3212', stripe_user_id: '2' })

  # Generate 5 tickets for each brand
  Ticket.destroy_all
  [amc, regal, cinemark].each do |b|
    20.times { ensure_ticket(b, { code: rand.to_s[2..11] })}
  end

  # Destroy all purchase orders and create new ones
  PurchaseOrder.destroy_all
  5.times { ensure_purchase_order(user, { price: 20 }) }
  30.times { ensure_purchase_order(user2, { price: 20 }) }

  # Link tickets with purchase_orders
  last_ticket_id = Ticket.last.id
  PurchaseOrder.all.each do |p|
    ticket = Ticket.find(last_ticket_id)
    ticket.purchase_order_id = p.id
    if last_ticket_id % 2 == 0
      ticket.status = 'used'
    end
    ticket.save
    last_ticket_id -= 1
  end

  Ticket.first(5).each do |ticket|
    p = PurchaseOrder.first
    ticket.purchase_order_id = p.id
    ticket.save
  end

  puts '----User count----'
  puts User.count
  puts '----PaymentProfile count----'
  puts PaymentProfile.count
  puts '----Brand count----'
  puts Brand.count
  puts '----ticket count----'
  puts Ticket.count
  puts '----PurchaseOrder count----'
  puts PurchaseOrder.count
end
