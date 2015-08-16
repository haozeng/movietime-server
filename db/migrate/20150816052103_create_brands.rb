class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.float :price

      t.timestamps null: false
    end

    add_attachment :brands, :logo
  end
end
