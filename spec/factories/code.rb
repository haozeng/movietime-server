FactoryGirl.define do
  factory :code do
    code { rand.to_s[2..11] }
    brand
    purchase_order nil
  end
end