class AddCashierCodeToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :cashier_code, :string
  end
end
