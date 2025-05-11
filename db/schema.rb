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

ActiveRecord::Schema[8.0].define(version: 2025_05_11_034709) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "critic_id", null: false
    t.integer "edition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "publication"
    t.index ["critic_id"], name: "index_attendances_on_critic_id"
    t.index ["edition_id"], name: "index_attendances_on_edition_id"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.boolean "standalone", default: false, null: false
    t.index ["edition_id", "position"], name: "index_categories_on_edition_id_and_position", unique: true
    t.index ["edition_id"], name: "index_categories_on_edition_id"
  end

  create_table "critics", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "publication"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_critics_on_slug", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.integer "festival_id", null: false
    t.integer "year"
    t.string "code"
    t.string "url"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["festival_id", "slug"], name: "index_editions_on_festival_id_and_slug", unique: true
    t.index ["festival_id"], name: "index_editions_on_festival_id"
  end

  create_table "festivals", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "url"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_festivals_on_slug", unique: true
  end

  create_table "films", force: :cascade do |t|
    t.string "title"
    t.string "original_title"
    t.string "director"
    t.string "country"
    t.integer "year"
    t.decimal "overall_average_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "normalized_title", null: false
    t.index ["slug"], name: "index_films_on_slug", unique: true
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "critic_id", null: false
    t.integer "selection_id", null: false
    t.decimal "score", precision: 2, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "review_url"
    t.text "impression"
    t.index ["critic_id"], name: "index_ratings_on_critic_id"
    t.index ["selection_id"], name: "index_ratings_on_selection_id"
  end

  create_table "selections", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.integer "film_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "average_rating"
    t.integer "category_id"
    t.index ["category_id"], name: "index_selections_on_category_id"
    t.index ["edition_id"], name: "index_selections_on_edition_id"
    t.index ["film_id"], name: "index_selections_on_film_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sign_in_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sign_in_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "userable_type", null: false
    t.integer "userable_id", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "critics"
  add_foreign_key "attendances", "editions"
  add_foreign_key "categories", "editions"
  add_foreign_key "editions", "festivals"
  add_foreign_key "ratings", "critics"
  add_foreign_key "ratings", "selections"
  add_foreign_key "selections", "categories"
  add_foreign_key "selections", "editions"
  add_foreign_key "selections", "films"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
end
