class ChangeColumnsTypeBoolean < ActiveRecord::Migration
  def self.up
  	change_column :accounts, :active, :boolean, :default => true
  	change_column :contracts, :active, :boolean, :default => true
  	change_column :contracts, :autopay, :boolean, :default => false
  	change_column :transactions, :completed, :boolean, :default => false
  end

  def self.down
  	change_column :accounts, :active, :integer
  	change_column :contracts, :active, :integer
  	change_column :contracts, :autopay, :integer
  	change_column :transactions, :completed, :integer
  end
end
