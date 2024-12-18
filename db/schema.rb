# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_29_170114) do
  create_table "clients", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "province"
    t.string "postal_code"
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "soldtoid"
  end

  create_table "contacts", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "phone1"
    t.string "phone2"
    t.string "email"
    t.string "notes"
    t.integer "client_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "location_id"
    t.integer "crm_object_id"
  end

  create_table "contacts_devices", id: false, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "contact_id"
    t.integer "device_id"
  end

  create_table "counters", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "reading_id"
    t.integer "pm_code_id"
    t.integer "value"
    t.string "unit"
  end

  create_table "device_stats", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.float "c_monthly"
    t.float "bw_monthly"
    t.float "vpy", default: 2.0
    t.integer "device_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "bw_daily"
    t.float "c_daily"
  end

  create_table "devices", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "crm_object_id"
    t.integer "model_id"
    t.integer "client_id"
    t.string "serial_number"
    t.integer "location_id"
    t.integer "primary_tech_id"
    t.integer "backup_tech_id"
    t.boolean "active"
    t.boolean "under_contract"
    t.boolean "do_pm"
    t.string "pm_counter_type", default: "0"
    t.float "pm_visits_min"
    t.text "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "team_id"
    t.date "install_date"
    t.date "earliest_pm_date"
    t.string "acctmgr"
    t.boolean "crm_active"
    t.boolean "crm_under_contract"
    t.boolean "crm_do_pm"
  end

  create_table "locations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "province"
    t.string "post_code"
    t.string "notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "shiptoid"
    t.integer "client_id"
    t.integer "team_id"
  end

  create_table "logs", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "technician_id"
    t.integer "device_id"
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "model_groups", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "color_flag"
  end

  create_table "model_targets", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "maint_code"
    t.integer "target"
    t.integer "model_group_id"
    t.string "unit"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "label"
    t.string "section"
  end

  create_table "models", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "nm"
    t.integer "model_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "neglecteds", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "device_id"
    t.date "next_visit"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "news", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.text "note"
    t.date "activate"
    t.boolean "urgent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "show_flag", default: true
  end

  create_table "outstanding_pms", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "device_id"
    t.string "code"
    t.date "next_pm_date"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "parts", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.float "price"
    t.string "new_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "parts_for_pms", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "model_group_id"
    t.integer "pm_code_id"
    t.integer "choice"
    t.integer "part_id"
    t.float "quantity"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "pm_codes", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "colorclass"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "preferences", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "default_notes"
    t.string "default_units_to_show"
    t.integer "upcoming_interval"
    t.string "default_to_email"
    t.string "default_subject"
    t.string "default_from_email"
    t.text "default_message"
    t.string "default_sig"
    t.integer "max_lines"
    t.integer "technician_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lines_per_page"
    t.string "default_root_path", default: "/devices/my_pm_list"
    t.boolean "showbackup"
    t.integer "pm_list_freq", default: 0
    t.integer "pm_list_freq_unit"
    t.boolean "mobile", default: true
  end

  create_table "reading_targets", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "target"
    t.integer "model_group_id"
    t.integer "counter_id"
    t.integer "counter_type_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "readings", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.date "taken_at"
    t.string "notes"
    t.integer "device_id"
    t.integer "technician_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "ptn1_file_name"
    t.string "ptn1_content_type"
    t.integer "ptn1_file_size"
    t.datetime "ptn1_updated_at", precision: nil
  end

  create_table "sessions", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "teams", primary_key: "team_id", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "crm_name"
    t.string "warehouse_id"
    t.integer "manager_id"
  end

  create_table "technicians", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "team_id"
    t.string "first_name"
    t.string "last_name"
    t.string "friendly_name"
    t.string "sharp_name"
    t.integer "car_stock_number"
    t.string "email", default: "", null: false
    t.string "crm_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "admin", default: false, null: false
    t.boolean "manager", default: false
    t.date "sent_date"
  end

  create_table "transfers", charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.string "tx_file_name"
    t.string "tx_type"
    t.integer "tx_file_size"
    t.datetime "tx_update_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "unreads", id: :integer, charset: "latin1", collation: "latin1_swedish_ci", force: :cascade do |t|
    t.integer "technician_id"
    t.integer "news_id"
    t.index ["news_id"], name: "index_unreads_on_news_id"
    t.index ["technician_id"], name: "index_unreads_on_technician_id"
  end

  add_foreign_key "unreads", "news"
  add_foreign_key "unreads", "technicians"
end
