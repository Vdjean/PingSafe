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

ActiveRecord::Schema[7.1].define(version: 2025_12_02_105333) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.bigint "ping_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ping_id"], name: "index_chats_on_ping_id"
  end

  create_table "levels", force: :cascade do |t|
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "chat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "pings", force: :cascade do |t|
    t.date "date"
    t.time "heure"
    t.text "comment"
    t.string "photo"
    t.decimal "latitude"
    t.decimal "longitude"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pings_on_user_id"
  end

  create_table "rewards", force: :cascade do |t|
    t.string "reward_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_levels", force: :cascade do |t|
    t.string "level_name"
    t.bigint "user_id", null: false
    t.bigint "level_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level_id"], name: "index_user_levels_on_level_id"
    t.index ["user_id"], name: "index_user_levels_on_user_id"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reward_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reward_id"], name: "index_user_rewards_on_reward_id"
    t.index ["user_id"], name: "index_user_rewards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "pseudo"
    t.string "phone"
    t.integer "score"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chats", "pings"
  add_foreign_key "messages", "chats"
  add_foreign_key "pings", "users"
  add_foreign_key "user_levels", "levels"
  add_foreign_key "user_levels", "users"
  add_foreign_key "user_rewards", "rewards"
  add_foreign_key "user_rewards", "users"
end
