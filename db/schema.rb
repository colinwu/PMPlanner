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

ActiveRecord::Schema.define(version: 20170816014739) do

  create_table "clients", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "address",     limit: 255
    t.string   "city",        limit: 255
    t.string   "province",    limit: 255
    t.string   "postal_code", limit: 255
    t.text     "notes",       limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "soldtoid",    limit: 4
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "phone1",        limit: 255
    t.string   "phone2",        limit: 255
    t.string   "email",         limit: 255
    t.string   "notes",         limit: 255
    t.integer  "client_id",     limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "location_id",   limit: 4
    t.integer  "crm_object_id", limit: 4
  end

  create_table "contacts_devices", id: false, force: :cascade do |t|
    t.integer "contact_id", limit: 4
    t.integer "device_id",  limit: 4
  end

  create_table "counters", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reading_id", limit: 4
    t.integer  "pm_code_id", limit: 4
    t.integer  "value",      limit: 4
    t.string   "unit",       limit: 255
  end

  create_table "device_stats", force: :cascade do |t|
    t.float    "c_monthly",  limit: 24
    t.float    "bw_monthly", limit: 24
    t.float    "vpy",        limit: 24, default: 2.0
    t.integer  "device_id",  limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "devices", force: :cascade do |t|
    t.string   "installed_base_id", limit: 255
    t.string   "crm_object_id",     limit: 255
    t.string   "alternate_id",      limit: 255
    t.integer  "model_id",          limit: 4
    t.integer  "client_id",         limit: 4
    t.string   "serial_number",     limit: 255
    t.integer  "location_id",       limit: 4
    t.integer  "primary_tech_id",   limit: 4
    t.integer  "backup_tech_id",    limit: 4
    t.boolean  "active"
    t.boolean  "under_contract"
    t.boolean  "do_pm"
    t.string   "pm_counter_type",   limit: 255,   default: "0"
    t.float    "pm_visits_min",     limit: 24
    t.text     "notes",             limit: 65535
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "team_id",           limit: 4
  end

  create_table "locations", force: :cascade do |t|
    t.string   "address1",   limit: 255
    t.string   "address2",   limit: 255
    t.string   "city",       limit: 255
    t.string   "province",   limit: 255
    t.string   "post_code",  limit: 255
    t.string   "notes",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "shiptoid",   limit: 4
    t.integer  "client_id",  limit: 4
    t.integer  "team_id",    limit: 4
  end

  create_table "logs", force: :cascade do |t|
    t.integer  "technician_id", limit: 4
    t.integer  "device_id",     limit: 4
    t.text     "message",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "model_groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "color_flag"
  end

  create_table "model_targets", force: :cascade do |t|
    t.string   "maint_code",     limit: 255
    t.integer  "target",         limit: 4
    t.integer  "model_group_id", limit: 4
    t.string   "unit",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label",          limit: 255
    t.string   "section",        limit: 255
  end

  create_table "models", force: :cascade do |t|
    t.string   "nm",             limit: 255
    t.integer  "model_group_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "neglecteds", force: :cascade do |t|
    t.integer  "device_id",  limit: 4
    t.date     "next_visit"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "outstanding_pms", force: :cascade do |t|
    t.integer  "device_id",    limit: 4
    t.string   "code",         limit: 255
    t.date     "next_pm_date"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "parts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.float    "price",       limit: 24
    t.string   "new_name",    limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "parts_for_pms", force: :cascade do |t|
    t.integer  "model_group_id", limit: 4
    t.integer  "pm_code_id",     limit: 4
    t.integer  "choice",         limit: 4
    t.integer  "part_id",        limit: 4
    t.float    "quantity",       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pm_codes", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "colorclass",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "preferences", force: :cascade do |t|
    t.text     "default_notes",         limit: 65535
    t.string   "default_units_to_show", limit: 255
    t.integer  "upcoming_interval",     limit: 4
    t.string   "default_to_email",      limit: 255
    t.string   "default_subject",       limit: 255
    t.string   "default_from_email",    limit: 255
    t.text     "default_message",       limit: 65535
    t.string   "default_sig",           limit: 255
    t.integer  "max_lines",             limit: 4
    t.integer  "technician_id",         limit: 4
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "lines_per_page",        limit: 4
    t.string   "default_root_path",     limit: 255,   default: "/devices/my_pm_list"
    t.boolean  "showbackup"
  end

  create_table "reading_targets", force: :cascade do |t|
    t.integer  "target",          limit: 4
    t.integer  "model_group_id",  limit: 4
    t.integer  "counter_id",      limit: 4
    t.integer  "counter_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "readings", force: :cascade do |t|
    t.date     "taken_at"
    t.string   "notes",             limit: 255
    t.integer  "device_id",         limit: 4
    t.integer  "technician_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ptn1_file_name",    limit: 255
    t.string   "ptn1_content_type", limit: 255
    t.integer  "ptn1_file_size",    limit: 4
    t.datetime "ptn1_updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "teams", primary_key: "team_id", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "crm_name",     limit: 255
    t.string   "warehouse_id", limit: 255
    t.integer  "manager_id",   limit: 4
  end

  create_table "technicians", force: :cascade do |t|
    t.integer  "team_id",            limit: 4
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "friendly_name",      limit: 255
    t.string   "sharp_name",         limit: 255
    t.integer  "car_stock_number",   limit: 4
    t.string   "email",              limit: 255, default: "",    null: false
    t.string   "crm_id",             limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip", limit: 255
    t.string   "last_sign_in_ip",    limit: 255
    t.boolean  "admin",                          default: false, null: false
    t.boolean  "manager",                        default: false
  end

  add_index "technicians", ["email"], name: "index_technicians_on_email", unique: true, using: :btree

  create_table "transfers", force: :cascade do |t|
    t.integer  "from_team_id", limit: 4
    t.integer  "to_team_id",   limit: 4
    t.integer  "device_id",    limit: 4
    t.boolean  "accepted",               default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

end
