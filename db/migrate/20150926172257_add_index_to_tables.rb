class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :purchase_orders, :user_id
    add_index :payment_profiles, :user_id
    add_index :tickets, :brand_id
    add_index :tickets, :purchase_order_id
    add_index :tickets, [:brand_id, :purchase_order_id]    
  end
end
