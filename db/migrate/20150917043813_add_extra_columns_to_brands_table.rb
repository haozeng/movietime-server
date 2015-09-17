class AddExtraColumnsToBrandsTable < ActiveRecord::Migration
  def change
    add_column :brands, :tos, :text
    add_column :brands, :redeem_instructions, :text
  end
end