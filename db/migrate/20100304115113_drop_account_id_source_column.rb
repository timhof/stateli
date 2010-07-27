class DropAccountIdSourceColumn < ActiveRecord::Migration
  def self.up
  	remove_column :transactions, :account_id_source
  	rename_column :transactions, :account_id_dest, :account_id
  end

  def self.down
    add_column :transactions, :account_id_source, :integer
  	rename_column :transactions, :account_id, :account_id_dest
  end
end
