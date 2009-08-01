class AddActiveToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :active, :integer
  end

  def self.down
    remove_column :accounts, :active
  end
end
