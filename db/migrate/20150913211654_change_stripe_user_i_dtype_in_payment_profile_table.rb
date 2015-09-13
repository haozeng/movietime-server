class ChangeStripeUserIDtypeInPaymentProfileTable < ActiveRecord::Migration
  def change
    change_column :payment_profiles, :stripe_user_id, :string
  end
end
