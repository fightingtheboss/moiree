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

ActiveRecord::Schema[7.1].define(version: 2024_05_25_182520) do
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
    t.decimal "overall_average_rating", precision: 2, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_films_on_slug", unique: true
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
    t.decimal "average_rating", precision: 2, scale: 1
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

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.integer "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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

  add_foreign_key "attendances", "critics"
  add_foreign_key "attendances", "editions"
  add_foreign_key "categories", "editions"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "films"
  add_foreign_key "editions", "festivals"
  add_foreign_key "ratings", "critics"
  add_foreign_key "ratings", "selections"
  add_foreign_key "selections", "categories"
  add_foreign_key "selections", "editions"
  add_foreign_key "selections", "films"
  add_foreign_key "sessions", "users"
  add_foreign_key "sign_in_tokens", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
