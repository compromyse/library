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

ActiveRecord::Schema[8.1].define(version: 2026_10_15_150822) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "interactions", force: :cascade do |t|
    t.integer "age", null: false
    t.integer "gender", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "estimated_time", null: false
    t.index ["created_at"], name: "index_interactions_on_created_at"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "primary_need", null: false
    t.text "interaction_description", null: false
    t.bigint "interaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "primary_need_other_detail"
    t.index ["interaction_id"], name: "index_issues_on_interaction_id"
  end

  create_table "service_plan_interactions", force: :cascade do |t|
    t.bigint "service_plan_id", null: false
    t.date "date", null: false
    t.integer "primary_need", null: false
    t.text "primary_need_other_detail"
    t.text "action_referrals", null: false
    t.bigint "point_person_id"
    t.string "point_person_name"
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_person_id"], name: "index_service_plan_interactions_on_point_person_id"
    t.index ["service_plan_id"], name: "index_service_plan_interactions_on_service_plan_id"
  end

  create_table "service_plans", force: :cascade do |t|
    t.string "client_name", null: false
    t.string "contact"
    t.date "date_of_contact", null: false
    t.text "background"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "issues", "interactions"
  add_foreign_key "service_plan_interactions", "service_plans"
  add_foreign_key "service_plan_interactions", "users", column: "point_person_id"
end
