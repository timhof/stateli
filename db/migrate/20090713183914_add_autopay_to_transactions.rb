class AddAutopayToTransactions < ActiveRecord::Migration
  def self.up
  	add_column :transactions, :autopay, :boolean, :default => false
  end

  def self.down
    remove_column :transactions, :autopay
  end
end