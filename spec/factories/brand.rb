FactoryGirl.define do
  factory :brand do
    name { ['AMC', 'Regal', 'Cinemarks'].sample }
    price 9.5
    logo { fixture_file_upload(Rails.root.join('spec', 'pictures', 'amc.png'), 'image/png') }
    original_price 13

    trait :available do
      status true
    end
  end
end