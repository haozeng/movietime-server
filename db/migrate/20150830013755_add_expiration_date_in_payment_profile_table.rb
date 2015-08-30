class AddExpirationDateInPaymentProfileTable < ActiveRecord::Migration
  def change
    add_column :payment_profiles, :exp, :string
  end
end
