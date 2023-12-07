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

ActiveRecord::Schema[7.1].define(version: 2023_11_18_122812) do
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
    t.datetime "discarded_at"
    t.integer "vehicle_id", null: false
    t.index ["user_id", "created_at"], name: "index_daily_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_daily_logs_on_user_id"
  end

  create_table "frequent_destinations", force: :cascade do |t|
    t.string "destination_name", null: false
    t.text "destination_note", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_frequent_destinations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", null: false
    t.string "email", default: "", null: false
    t.string "telephone", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "discarded_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "vehicle_name", null: false
    t.string "number", null: false
    t.string "manufacture", null: false
    t.integer "current_drive_distance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["vehicle_name", "number", "manufacture"], name: "index_vehicles_on_vehicle_name_and_number_and_manufacture", unique: true
  end

  add_foreign_key "daily_logs", "users", on_update: :restrict, on_delete: :restrict
end
