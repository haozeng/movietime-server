FactoryGirl.define do
  factory :ticket do
    code { rand.to_s[2..11] }
    brand
    purchase_order nil
    created_at { Time.now }
  end
end