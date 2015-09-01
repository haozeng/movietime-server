class AddDefaultInPaymentProfilesTable < ActiveRecord::Migration
  def change
    add_column :payment_profiles, :default, :boolean, default: false
  end
end
