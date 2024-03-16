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

ActiveRecord::Schema[7.1].define(version: 2024_03_15_193319) do
  create_table "admins", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_categories_on_edition_id"
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "film_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["film_id"], name: "index_categorizations_on_film_id"
  end

  create_table "critics", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "publication"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["festival_id"], name: "index_editions_on_festival_id"
  end

  create_table "festivals", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "url"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "films", force: :cascade do |t|
    t.string "title"
    t.string "original_title"
    t.string "director"
    t.string "country"
    t.integer "year"
    t.decimal "overall_average_rating", precision: 2, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ratings", force: :cascade do |t|
    t.integer "critic_id", null: false
    t.integer "selection_id", null: false
    t.decimal "score", precision: 2, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["critic_id"], name: "index_ratings_on_critic_id"
    t.index ["selection_id"], name: "index_ratings_on_selection_id"
  end

  create_table "selections", force: :cascade do |t|
    t.integer "edition_id", null: false
    t.integer "film_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "categories", "editions"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "films"
  add_foreign_key "editions", "festivals"
  add_foreign_key "ratings", "critics"
  add_foreign_key "ratings", "selections"
  add_foreign_key "selections", "editions"
  add_foreign_key "selections", "films"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
end
