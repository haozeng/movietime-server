json.payment_profiles @payment_profiles do |payment_profile|
  json.id payment_profile.id
  json.user_id payment_profile.user_id
  json.card_type payment_profile.card_type
  json.last_four_digits payment_profile.last_four_digits.to_s
  json.exp payment_profile.exp
end