class ChangeTransDateColumnTypeDatetime < ActiveRecord::Migration
  def self.up
  	change_column :transactions, :trans_date, :datetime
  end

  def self.down
  	change_column :transactions, :trans_date, :date
  end
end
