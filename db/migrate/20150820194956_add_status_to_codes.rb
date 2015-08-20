class AddStatusToCodes < ActiveRecord::Migration
  def change
    add_column :codes, :status, :string, :default => "unused"
  end
end
