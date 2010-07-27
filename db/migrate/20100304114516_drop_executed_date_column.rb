class DropExecutedDateColumn < ActiveRecord::Migration

  def self.up
  	remove_column :transactions, :executed_date
  	rename_column :transactions, :scheduled_date, :trans_date
  end

  def self.down
    add_column :transactions, :executed_date, :date
  	rename_column :transactions, :trans_date, :scheduled_date
  end
end
