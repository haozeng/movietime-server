class AddOriginalPriceInBrandTable < ActiveRecord::Migration
  def change
    add_column :brands, :original_price, :float
  end
end
