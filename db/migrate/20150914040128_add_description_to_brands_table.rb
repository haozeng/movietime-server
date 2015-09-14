class AddDescriptionToBrandsTable < ActiveRecord::Migration
  def change
    add_column :brands, :description, :string
  end
end
