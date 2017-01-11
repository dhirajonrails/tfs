# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161008170937) do

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.string   "mobile"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "balance_limit"
    t.index ["user_id"], name: "index_admins_on_user_id", using: :btree
  end

  create_table "bank_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "ifsc_code"
    t.string   "city"
    t.string   "state"
    t.string   "branch"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "district"
    t.integer  "pincode"
    t.string   "contact"
    t.index ["ifsc_code"], name: "index_bank_details_on_ifsc_code", using: :btree
  end

  create_table "beneficiaries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "account_number"
    t.string   "ifsc_code"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "bank_detail_id"
    t.string   "bankname"
    t.string   "state"
    t.string   "district"
    t.string   "city"
    t.string   "branch"
    t.string   "address"
    t.boolean  "hidden"
    t.index ["account_number"], name: "index_beneficiaries_on_account_number", using: :btree
    t.index ["bank_detail_id"], name: "index_beneficiaries_on_bank_detail_id", using: :btree
  end

  create_table "change_limits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "changable_id"
    t.string   "changable_type"
    t.integer  "amount"
    t.string   "note"
    t.string   "action"
    t.string   "source"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "previous_limit"
    t.integer  "current_limit"
    t.string   "less"
    t.string   "cust_id"
    t.boolean  "quick_request"
    t.string   "status"
    t.string   "distributor_mobile"
    t.index ["changable_type", "changable_id"], name: "index_change_limits_on_changable_type_and_changable_id", using: :btree
  end

  create_table "distributors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "balance_limit"
    t.string   "mobile"
  end

  create_table "flashes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "message"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "source"
    t.integer  "user_id"
    t.string   "mobile"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "distributor_id"
    t.integer  "balance_limit"
    t.string   "dist_id"
    t.integer  "quick_limit"
    t.index ["distributor_id"], name: "index_merchants_on_distributor_id", using: :btree
    t.index ["mobile"], name: "index_merchants_on_mobile", using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.boolean  "read_by_admin"
    t.boolean  "read_by_distributor"
    t.integer  "transaction_id"
    t.integer  "distributor_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.boolean  "quick_transfer"
    t.index ["distributor_id"], name: "index_notifications_on_distributor_id", using: :btree
    t.index ["transaction_id"], name: "index_notifications_on_transaction_id", using: :btree
  end

  create_table "profiles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "profileable_id"
    t.string   "profileable_type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name_of_business"
    t.date     "dob"
    t.string   "address1"
    t.string   "address2"
    t.string   "state"
    t.string   "city"
    t.integer  "pincode"
    t.string   "reference_name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "mobileno"
    t.index ["profileable_type", "profileable_id"], name: "index_profiles_on_profileable_type_and_profileable_id", using: :btree
  end

  create_table "request_limits", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "requestable_id"
    t.string   "requestable_type"
    t.integer  "amount"
    t.string   "bank"
    t.string   "status"
    t.string   "tracking_id"
    t.boolean  "quick_request"
    t.string   "remark"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "cust_id"
    t.boolean  "hidden"
    t.boolean  "updated"
    t.string   "distributor_mobile"
    t.index ["requestable_type", "requestable_id"], name: "index_request_limits_on_requestable_type_and_requestable_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "senders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "name"
    t.string   "mobile"
    t.string   "id_proof"
    t.text     "address",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["mobile"], name: "index_senders_on_mobile", using: :btree
  end

  create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "txt_id"
    t.string   "status"
    t.integer  "amount"
    t.integer  "charges"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "admin_remark"
    t.string   "merchant_remark"
    t.boolean  "quick_transfer"
    t.integer  "previous_limit"
    t.integer  "current_limit"
    t.boolean  "hidden"
    t.boolean  "updated"
    t.string   "sender_mobile"
    t.string   "beneficiary_account_number"
    t.string   "merchant_mobile"
    t.string   "distributor_mobile"
    t.boolean  "downloaded"
    t.string   "admin_mobile"
    t.index ["sender_mobile", "txt_id"], name: "index_transactions_on_sender_mobile_and_txt_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "mobile"
    t.string   "status"
    t.integer  "balance_limit"
    t.integer  "quick_limit"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
