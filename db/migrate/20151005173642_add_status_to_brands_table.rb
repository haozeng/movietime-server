class AddStatusToBrandsTable < ActiveRecord::Migration
  def change
    add_column :brands, :status, :boolean, default: false
  end
end
