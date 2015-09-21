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
  amc = ensure_brand(name: 'amc', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'amc.png'), 'r'), description: 'Available at at any AMC®, AMC Showplace, Loews®, Cineplex Odeon, Magic Johnson and Star theatres.', title: 'AMC Green E-Ticket',
                     tos: "• The AMC Gold Ticket is valid for one admission and redeemable at any AMC, AMC Loews, AMC Showplace, Cineplex Odeon, Magic Johnson and Star Theatres, excluding Canadian theatres.\n• "\
                          "Programs subject to a surcharge: 3D, IMAX and AMC ETX, alternate content, AMC Dine-In Theatres and premium services.\n• "\
                          "Locations surcharges may also be applied at select theatres. AMC reserves the right to change any surcharge fee without notice.\n• "\
                          "Unauthorized reproductions not allowed AMC gold tickets are discount items that are NOT eligible toward earning AMC stubs rewards, either at the time of purchase OR at time of redemption.\n• "\
                          "Valid seven days a week.\n• "\
                          "Please visit amctheatres.com for additional information.",
                     redeem_instructions: "Present this E-Ticket at the theatre box office. This E-Ticket contains a unique barcode valid for ONE ENTRY ONLY.\n\n"\
                                          "This E-Ticket becomes INVALID once scanned. No Refunds or exchanges. For information regarding this ticket, please contact support@movietime.us.")

  regal = ensure_brand(name: 'regal', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'regal.png'), 'r'), description: 'Available at any Regal Cinemas®, Edwards® Theatres, United Artists Theatres and Hollywood Theaters.', title: 'Regal Premiere E-Ticket',
                       tos: "• Premiere Tickets must be redeemed at the theatre box office.\n• "\
                            "Premiere Tickets are not valid for special events, private screenings or online purchases.\n• "\
                            "Premiere tickets have surcharge fees for all IMAX, Large Format, RPX or 3-D Films. Location surcharge fees may also be applied at select theatres.\n• "\
                            "Regal Entertainment Group reserves the right to change any upgrade, surcharge or location surcharge fee without notice.",
                       redeem_instructions: "Present this E-Ticket at the theatre box office. This E-Ticket contains a unique QRCode valid for ONE ENTRY ONLY.\n\n"\
                                            "This E-Ticket becomes INVALID once scanned. No Refunds or exchanges. For information regarding this ticket, please contact support@movietime.us.")

  cinemark = ensure_brand(name: 'cinemark', original_price: 13, price: 9.5, logo: File.open(Rails.root.join('spec', 'pictures', 'cinemark.png'), 'r'), description: 'Available at any Cinemark Theatre nationwide.', title: 'Cinemark Platinum E-Ticket',
                          tos: "• Each card is valid for one box office admission.\n• "\
                               "Additional premiums may be applied for specially priced films and/or events which are priced higher than normal box office ticket pricing.\n• "\
                               "Must be presented at box office.\n• "\
                               "This ticket is non-refundable.\n• "\
                               "Not redeemable or exchangeable for cash except where required by law.\n• "\
                               "Tickets have surcharge fees for IMAX, Large Format or 3-D Films.",
                          redeem_instructions: "Present this E-Ticket at the theatre box office. This E-Ticket contains a unique barcode valid for ONE ENTRY ONLY.\n\n"\
                                               "This E-Ticket becomes INVALID once scanned. No Refunds or exchanges. For information regarding this ticket, please contact support@movietime.us.")

  user = ensure_user(email: 'hzeng1989@gmail.com', password: '123456', password_confirmation: '123456',
                     first_name: 'hao', last_name: 'zeng')
  user2 = ensure_user(email: 'daceywang@gmail.com', password: '123456', password_confirmation: '123456',
                     first_name: 'yefei', last_name: 'wang')

  # Generate 20 tickets for each brand
  Ticket.destroy_all
  [amc, regal, cinemark].each do |b|
    20.times { ensure_ticket(b, { code: rand.to_s[2..11] })}
  end

  # Destroy all purchase orders and create new ones
  PurchaseOrder.destroy_all
  20.times { ensure_purchase_order(user, { price: 20 }) }
  20.times { ensure_purchase_order(user2, { price: 20 }) }

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

  PaymentProfile.destroy_all

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