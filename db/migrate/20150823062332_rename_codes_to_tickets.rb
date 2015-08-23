class RenameCodesToTickets < ActiveRecord::Migration
  def self.up
    rename_table :codes, :tickets
  end 

  def self.down
    rename_table :tickets, :codes
  end
end
