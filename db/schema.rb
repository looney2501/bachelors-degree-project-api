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

ActiveRecord::Schema.define(version: 2023_05_10_163744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "free_days", force: :cascade do |t|
    t.date "date"
    t.string "free_day_type"
    t.string "free_days_container_type", null: false
    t.bigint "free_days_container_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["free_days_container_type", "free_days_container_id"], name: "index_free_days_on_free_days_container"
  end

  create_table "intervals", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "available_overlapping_plannings"
    t.integer "requested_days"
    t.string "type", null: false
    t.bigint "planning_session_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["planning_session_id"], name: "index_intervals_on_planning_session_id"
  end

  create_table "planning_sessions", force: :cascade do |t|
    t.integer "available_free_days", null: false
    t.integer "year", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["year"], name: "index_planning_sessions_on_year"
  end

end
