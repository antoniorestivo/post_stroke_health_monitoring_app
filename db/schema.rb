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

ActiveRecord::Schema[8.1].define(version: 2026_02_02_045558) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conditions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.boolean "support"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "video_url"
  end

  create_table "health_metrics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "journal_template_id"
    t.string "metric_data_type"
    t.string "metric_name"
    t.string "metric_unit_name"
    t.datetime "updated_at", null: false
    t.string "warning_modifier"
    t.float "warning_threshold"
  end

  create_table "journal_templates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
  end

  create_table "journals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "health_routines"
    t.string "image_url"
    t.bigint "journal_template_id"
    t.jsonb "metrics"
    t.datetime "updated_at", null: false
    t.string "video_url"
  end

  create_table "treatment_retrospects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "feedback"
    t.integer "rating"
    t.bigint "treatment_id"
    t.datetime "updated_at", null: false
  end

  create_table "treatments", force: :cascade do |t|
    t.bigint "condition_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "user_charts", force: :cascade do |t|
    t.string "chart_mode", default: "metric_vs_metric", null: false
    t.string "chart_type"
    t.datetime "created_at", null: false
    t.jsonb "options"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "x_label"
    t.string "y_label"
  end

  create_table "user_logins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "date_dimension_id"
    t.integer "month_dimension_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["date_dimension_id"], name: "index_user_logins_on_date_dimension_id"
    t.index ["month_dimension_id"], name: "index_user_logins_on_month_dimension_id"
    t.index ["user_id"], name: "index_user_logins_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", null: false
    t.boolean "demo", default: false
    t.string "email"
    t.boolean "email_confirmed", default: false, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.string "preferred_name"
    t.datetime "updated_at", null: false
    t.jsonb "usage_statistics"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conditions", "users"
  add_foreign_key "health_metrics", "journal_templates"
  add_foreign_key "journal_templates", "users"
  add_foreign_key "journals", "journal_templates"
  add_foreign_key "treatment_retrospects", "treatments"
  add_foreign_key "treatments", "conditions"
  add_foreign_key "user_charts", "users"
  add_foreign_key "user_logins", "users"
end
