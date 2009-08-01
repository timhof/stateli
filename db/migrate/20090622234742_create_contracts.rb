class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :name
      t.string :description
      t.date :date_start
      t.date :date_end
      t.string :type
      t.integer :user_id
      t.integer :autopay
      t.integer :autopay_account_id
      t.date :full_date
      t.integer :day_of_month
      t.integer :day_of_month_alt
      t.integer :weekday

      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
