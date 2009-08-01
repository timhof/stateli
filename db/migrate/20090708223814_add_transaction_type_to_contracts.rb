class AddTransactionTypeToContracts < ActiveRecord::Migration
  def self.up
  	add_column :contracts, :transaction_type, :string
  end

  def self.down
  	remove_column :contracts, :transaction_type, :string
  end
end
