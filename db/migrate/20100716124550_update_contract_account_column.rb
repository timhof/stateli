class UpdateContractAccountColumn < ActiveRecord::Migration
  def self.up
  	remove_column :contracts, :autopay_account_id
  	remove_column :contracts, :transaction_type
  	remove_column :contracts, :active
  	add_column :contracts, :account_id, :integer
  end

  def self.down
  	remove_column :contracts, :account_id
  	add_column :contracts, :autopay_account_id, :integer
  	add_column :contracts, :transaction_type, :string
  	add_column :contracts, :active, :boolean  
  end
end
