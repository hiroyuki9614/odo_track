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

ActiveRecord::Schema[7.1].define(version: 2023_10_30_081312) do
  create_table "daily_logs", force: :cascade do |t|
    t.datetime "departure_datetime", null: false
    t.datetime "arrival_datetime", null: false
    t.integer "departure_distance", null: false
    t.integer "arrival_distance", null: false
    t.string "departure_location", null: false
    t.string "arrival_location", null: false
    t.text "note", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_alcohol_check", default: false, null: false
    t.boolean "is_studless_tire", default: false, null: false
    t.integer "approval_status", default: 0, null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_daily_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", null: false
    t.string "email", null: false
    t.string "telephone", null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_admin", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.string "remember_digest", default: ""
  end

  add_foreign_key "daily_logs", "users", on_update: :restrict, on_delete: :restrict
end
