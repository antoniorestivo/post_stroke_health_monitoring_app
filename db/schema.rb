# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_04_25_232946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conditions", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.boolean "support"
    t.string "image_url"
    t.string "video_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "health_metrics", force: :cascade do |t|
    t.bigint "journal_template_id"
    t.string "metric_name"
    t.string "metric_data_type"
    t.string "metric_unit_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "journal_templates", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "journals", force: :cascade do |t|
    t.bigint "journal_template_id"
    t.text "description"
    t.string "image_url"
    t.string "video_url"
    t.text "health_routines"
    t.jsonb "metrics"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "treatment_retrospects", force: :cascade do |t|
    t.bigint "treatment_id"
    t.integer "rating"
    t.text "feedback"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "treatments", force: :cascade do |t|
    t.bigint "condition_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "conditions", "users"
  add_foreign_key "health_metrics", "journal_templates"
  add_foreign_key "journal_templates", "users"
  add_foreign_key "journals", "journal_templates"
  add_foreign_key "treatment_retrospects", "treatments"
  add_foreign_key "treatments", "conditions"
end
