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

ActiveRecord::Schema[8.1].define(version: 2026_05_17_161000) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
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
    t.datetime "created_at", null: false
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

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
  end

  create_table "attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "critic_id", null: false
    t.integer "edition_id", null: false
    t.string "publication"
    t.datetime "updated_at", null: false
    t.index ["critic_id"], name: "index_attendances_on_critic_id"
    t.index ["edition_id"], name: "index_attendances_on_edition_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "edition_id", null: false
    t.string "name"
    t.integer "position", null: false
    t.boolean "standalone", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id", "position"], name: "index_categories_on_edition_id_and_position", unique: true
    t.index ["edition_id"], name: "index_categories_on_edition_id"
  end

  create_table "critics", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "publication"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_critics_on_slug", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.integer "festival_id", null: false
    t.string "slug"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "year"
    t.index ["festival_id", "slug"], name: "index_editions_on_festival_id_and_slug", unique: true
    t.index ["festival_id"], name: "index_editions_on_festival_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration"
    t.integer "edition_id"
    t.text "embed"
    t.integer "podcast_id", null: false
    t.string "provider_id"
    t.datetime "published_at"
    t.string "slug"
    t.text "summary"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["edition_id"], name: "index_episodes_on_edition_id"
    t.index ["podcast_id"], name: "index_episodes_on_podcast_id"
    t.index ["published_at"], name: "index_episodes_on_published_at"
    t.index ["slug"], name: "index_episodes_on_slug", unique: true
  end

  create_table "festivals", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "short_name"
    t.string "slug"
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["slug"], name: "index_festivals_on_slug", unique: true
  end

  create_table "films", force: :cascade do |t|
    t.string "backdrop_path"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "director"
    t.string "normalized_title", null: false
    t.string "original_title"
    t.decimal "overall_average_rating"
    t.string "poster_path"
    t.boolean "rateable", default: true, null: false
    t.date "release_date"
    t.string "slug"
    t.text "summary"
    t.string "title"
    t.integer "tmdb_id"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["slug"], name: "index_films_on_slug", unique: true
  end

  create_table "podcasts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "platform", default: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id", null: false
    t.index ["slug"], name: "index_podcasts_on_slug", unique: true
    t.index ["user_id"], name: "index_podcasts_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "critic_id", null: false
    t.text "impression"
    t.string "review_url"
    t.decimal "score", precision: 2, scale: 1
    t.integer "selection_id", null: false
    t.integer "source_edition_id"
    t.datetime "updated_at", null: false
    t.boolean "walked_out", default: false, null: false
    t.index ["critic_id"], name: "index_ratings_on_critic_id"
    t.index ["selection_id"], name: "index_ratings_on_selection_id"
    t.index ["source_edition_id"], name: "index_ratings_on_source_edition_id"
  end

  create_table "selections", force: :cascade do |t|
    t.decimal "average_rating"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.integer "edition_id", null: false
    t.integer "film_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_selections_on_category_id"
    t.index ["edition_id"], name: "index_selections_on_edition_id"
    t.index ["film_id"], name: "index_selections_on_film_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sign_in_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sign_in_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.integer "userable_id", null: false
    t.string "userable_type", null: false
    t.boolean "verified", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable"
  end

  create_table "year_in_review_top_selections", force: :cascade do |t|
    t.decimal "bayesian_score"
    t.decimal "combined_average_rating"
    t.integer "combined_ratings_count"
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.integer "selection_id", null: false
    t.datetime "updated_at", null: false
    t.integer "year_in_review_id", null: false
    t.index ["selection_id"], name: "index_year_in_review_top_selections_on_selection_id"
    t.index ["year_in_review_id", "position"], name: "idx_yir_top_selections_on_yir_and_position", unique: true
    t.index ["year_in_review_id", "selection_id"], name: "idx_yir_top_selections_on_yir_and_selection", unique: true
    t.index ["year_in_review_id"], name: "index_year_in_review_top_selections_on_year_in_review_id"
  end

  create_table "year_in_reviews", force: :cascade do |t|
    t.integer "bombe_moiree_selection_id"
    t.datetime "created_at", null: false
    t.integer "critics_count", default: 0, null: false
    t.integer "editions_count", default: 0, null: false
    t.integer "films_count", default: 0, null: false
    t.integer "five_star_ratings_count", default: 0, null: false
    t.datetime "generated_at"
    t.integer "most_divisive_selection_id"
    t.integer "ratings_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.integer "zero_star_ratings_count", default: 0, null: false
    t.index ["bombe_moiree_selection_id"], name: "index_year_in_reviews_on_bombe_moiree_selection_id"
    t.index ["most_divisive_selection_id"], name: "index_year_in_reviews_on_most_divisive_selection_id"
    t.index ["year"], name: "index_year_in_reviews_on_year", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "critics"
  add_foreign_key "attendances", "editions"
  add_foreign_key "categories", "editions"
  add_foreign_key "editions", "festivals"
  add_foreign_key "episodes", "editions"
  add_foreign_key "episodes", "podcasts"
  add_foreign_key "podcasts", "users"
  add_foreign_key "ratings", "critics"
  add_foreign_key "ratings", "editions", column: "source_edition_id"
  add_foreign_key "ratings", "selections"
  add_foreign_key "selections", "categories"
  add_foreign_key "selections", "editions"
  add_foreign_key "selections", "films"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
  add_foreign_key "year_in_review_top_selections", "selections"
  add_foreign_key "year_in_review_top_selections", "year_in_reviews"
  add_foreign_key "year_in_reviews", "selections", column: "bombe_moiree_selection_id"
  add_foreign_key "year_in_reviews", "selections", column: "most_divisive_selection_id"
end
