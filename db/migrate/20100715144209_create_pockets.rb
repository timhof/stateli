class CreatePockets < ActiveRecord::Migration
  def self.up
    create_table :pockets do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end
    add_column :transactions, :pocket_id, :integer
    add_column :rules, :pocket_id, :integer
    remove_column :rules, :contract_id
  end

  def self.down
    drop_table :pockets
    remove_column :transactions, :pocket_id
    remove_column :rules, :pocket_id
    add_column :rules, :contract_id, :integer
  end
end
