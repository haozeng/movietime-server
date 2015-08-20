FactoryGirl.define do
  factory :purchase_order do
    price 20
    user
    created_at { Time.now }
  end
end