class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|

      t.string :name
      t.string :trans_field
      t.string :comp_type
      t.float :comp_amount
      t.string :comp_string
      t.date :comp_date
      t.string :comp_action
      t.integer :contract_id
      t.integer :account_id
      t.string :type
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end
