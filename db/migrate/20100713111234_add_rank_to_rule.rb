class AddRankToRule < ActiveRecord::Migration
  def self.up
  	add_column :rules, :rank, :integer
    remove_column :rules, :trans_field
  end

  def self.down
    remove_column :rules, :rank
    add_column :rules, :trans_field, :string
  end
end
