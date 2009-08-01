class AddAmountToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :amount, :float
  end

  def self.down
    remove_column :contracts, :amount
  end
end
