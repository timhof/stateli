class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :name
      t.string :description
      t.date :scheduled_date
      t.date :executed_date
      t.float :amount
      t.integer :completed
      t.integer :account_id_source
      t.integer :account_id_dest
      t.integer :contract_id
      t.string :type
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
