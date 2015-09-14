class AddTitleToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :title, :string
  end
end
