require 'rails_helper'

describe PaymentProfile do

  it 'the same user can not have two cards the same added' do
    create :payment_profile, user_id: 1, card_type: 'MC', last_four_digits: '1234'

    payment_profile = PaymentProfile.new(user_id: 1, card_type: 'MC', last_four_digits: '1234')
    expect(payment_profile.valid?).to be false

    payment_profile_two = PaymentProfile.new(user_id: 1, card_type: 'VI', last_four_digits: '1234')
    expect(payment_profile_two.valid?).to be true
  end

  it 'different user can have the same card added' do
    create :payment_profile, user_id: 1, card_type: 'MC', last_four_digits: '1234'

    payment_profile = PaymentProfile.new(user_id: 2, card_type: 'MC', last_four_digits: '1234')
    expect(payment_profile.valid?).to be true
  end

  it 'if card fails validation, it should not create itself in stripe' do
    create :payment_profile, user_id: 1, card_type: 'MC', last_four_digits: '1234'

    payment_profile = PaymentProfile.new(user_id: 1, card_type: 'MC', last_four_digits: '1234')
    expect(payment_profile.create_in_stripe('stripe_token')).to be false
  end
end