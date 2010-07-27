class AddAccountBalanceToTransaction < ActiveRecord::Migration
  def self.up
  	add_column :transactions, :account_balance, :float
  end

  def self.down
    remove_column :transactions, :account_balance
  end
end
