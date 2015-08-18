json.payment_profiles @payment_profiles do |payment_profile|
  json.id payment_profile.id
  json.user_id payment_profile.user_id
  json.brand payment_profile.brand
  json.last_four_digits payment_profile.last_four_digits
end