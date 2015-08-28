class ChangeBrandToCardTypeInPaymentProfileTable < ActiveRecord::Migration
  def change
    rename_column :payment_profiles, :brand, :card_type
  end
end
