json.user do
  json.id @user.id
  json.email @user.email
  json.first_name @user.first_name
  json.last_name @user.last_name
end

json.purchase_orders @tickets do |ticket|
  json.ticket_id ticket.id
  json.brand ticket.brand.name
  json.created_at ticket.purchase_order.created_at
  json.code ticket.code
  json.status ticket.status
end

json.payment_profiles @payment_profiles do |payment_profile|
  json.id payment_profile.id
  json.user_id payment_profile.user_id
  json.card_type payment_profile.card_type
  json.last_four_digits payment_profile.last_four_digits.to_s
  json.exp payment_profile.exp
end