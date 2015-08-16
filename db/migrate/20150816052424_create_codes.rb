class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.integer :brand_id
      t.string :code
      t.integer :purchase_order_id

      t.timestamps null: false
    end
  end
end
