class AddIosIdInUsers < ActiveRecord::Migration
  def change
    add_column :users, :ios_id, :string
  end
end
