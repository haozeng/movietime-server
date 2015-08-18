class CreatePaymentProfiles < ActiveRecord::Migration
  def change
    create_table :payment_profiles do |t|
      t.integer :user_id
      t.string :brand
      t.integer :last_four_digits
      t.integer :stripe_user_id

      t.timestamps null: false
    end
  end
end
