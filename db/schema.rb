# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150627233513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "assignments", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "role",            default: "Member"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["organization_id"], name: "index_assignments_on_organization_id", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.text     "message",                 default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "comments", ["order_id"], name: "index_comments_on_order_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "needs", force: true do |t|
    t.string   "name",        default: ""
    t.string   "flavor",      default: ""
    t.string   "placeholder", default: ""
    t.text     "description", default: ""
    t.boolean  "auto",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.string   "name",            default: ""
    t.date     "due"
    t.text     "description",     default: ""
    t.hstore   "event",           default: {},           null: false
    t.hstore   "needs",           default: {},           null: false
    t.string   "status",          default: "Unapproved"
    t.integer  "owner_id"
    t.integer  "organization_id"
    t.integer  "creative_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "subscriptions",   default: [],           null: false, array: true
    t.string   "progress",        default: "",           null: false
  end

  add_index "orders", ["creative_id"], name: "index_orders_on_creative_id", using: :btree
  add_index "orders", ["organization_id"], name: "index_orders_on_organization_id", using: :btree
  add_index "orders", ["owner_id"], name: "index_orders_on_owner_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.string   "role",                   default: "Unapproved"
    t.string   "phone",                  default: ""
    t.string   "flavor",                 default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",           null: false
    t.string   "encrypted_password",     default: "",           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "send_emails",            default: true,         null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
