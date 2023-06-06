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

ActiveRecord::Schema.define(version: 2023_06_06_121618) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "free_days", force: :cascade do |t|
    t.date "date"
    t.string "free_day_type"
    t.string "free_days_container_type", null: false
    t.bigint "free_days_container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["free_days_container_type", "free_days_container_id"], name: "index_free_days_on_free_days_container"
  end

  create_table "intervals", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "type"
    t.integer "importance_level"
    t.integer "available_overlapping_plannings"
    t.bigint "planning_session_id"
    t.bigint "vacation_request_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["planning_session_id"], name: "index_intervals_on_planning_session_id"
    t.index ["vacation_request_id"], name: "index_intervals_on_vacation_request_id"
  end

  create_table "planning_sessions", force: :cascade do |t|
    t.integer "available_free_days", null: false
    t.integer "year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "created"
    t.index ["year"], name: "index_planning_sessions_on_year", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.string "role"
    t.string "phone_number"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "vacation_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "planning_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["planning_session_id", "user_id"], name: "index_vacation_requests_on_planning_session_id_and_user_id", unique: true
    t.index ["planning_session_id"], name: "index_vacation_requests_on_planning_session_id"
    t.index ["user_id"], name: "index_vacation_requests_on_user_id"
  end

  create_table "vacations", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "planning_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["planning_session_id"], name: "index_vacations_on_planning_session_id"
    t.index ["user_id", "planning_session_id"], name: "index_vacations_on_user_id_and_planning_session_id", unique: true
    t.index ["user_id"], name: "index_vacations_on_user_id"
  end

  add_foreign_key "vacation_requests", "planning_sessions"
  add_foreign_key "vacation_requests", "users"
end
