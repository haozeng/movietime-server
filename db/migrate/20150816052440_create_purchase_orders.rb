class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer :user_id
      t.float :price

      t.timestamps null: false
    end
  end
end
