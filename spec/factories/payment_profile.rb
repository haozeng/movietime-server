FactoryGirl.define do
  factory :payment_profile do
    card_type 'MC'
    last_four_digits { rand.to_s[2..5] }
    user
  end
end