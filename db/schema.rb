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

ActiveRecord::Schema[7.1].define(version: 2025_12_01_164529) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.bigint "pings_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pings_id"], name: "index_chats_on_pings_id"
  end

  create_table "levels", force: :cascade do |t|
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "chats_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chats_id"], name: "index_messages_on_chats_id"
  end

  create_table "pings", force: :cascade do |t|
    t.date "date"
    t.time "time"
    t.text "comment"
    t.string "photo"
    t.float "latitude"
    t.float "longitude"
    t.bigint "users_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["users_id"], name: "index_pings_on_users_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_levels", force: :cascade do |t|
    t.bigint "users_id", null: false
    t.bigint "levels_id", null: false
    t.string "level_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["levels_id"], name: "index_user_levels_on_levels_id"
    t.index ["users_id"], name: "index_user_levels_on_users_id"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.bigint "rewards_id", null: false
    t.bigint "users_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rewards_id"], name: "index_user_rewards_on_rewards_id"
    t.index ["users_id"], name: "index_user_rewards_on_users_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "pseudo"
    t.string "password"
    t.string "phone"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "chats", "pings", column: "pings_id"
  add_foreign_key "messages", "chats", column: "chats_id"
  add_foreign_key "pings", "users", column: "users_id"
  add_foreign_key "user_levels", "levels", column: "levels_id"
  add_foreign_key "user_levels", "users", column: "users_id"
  add_foreign_key "user_rewards", "rewards", column: "rewards_id"
  add_foreign_key "user_rewards", "users", column: "users_id"
end
