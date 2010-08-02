# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100729103849) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.float    "balance"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",      :default => true
  end

  create_table "contracts", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.date     "date_start"
    t.date     "date_end"
    t.string   "type"
    t.integer  "user_id"
    t.boolean  "autopay",          :default => false
    t.date     "full_date"
    t.integer  "day_of_month"
    t.integer  "day_of_month_alt"
    t.integer  "weekday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.integer  "account_id"
  end

  create_table "pockets", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.string   "name"
    t.string   "comp_type"
    t.float    "comp_amount"
    t.string   "comp_string"
    t.date     "comp_date"
    t.string   "comp_action"
    t.integer  "account_id"
    t.string   "type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rank"
    t.integer  "pocket_id"
  end

  create_table "transactions", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "trans_date"
    t.float    "amount"
    t.boolean  "completed",       :default => false
    t.integer  "account_id"
    t.integer  "contract_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "autopay",         :default => false
    t.float    "account_balance"
    t.integer  "pocket_id"
    t.boolean  "active",          :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
