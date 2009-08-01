class AddActiveToContract < ActiveRecord::Migration
  def self.up
    add_column :contracts, :active, :integer
  end

  def self.down
    remove_column :contracts, :active
  end
end
