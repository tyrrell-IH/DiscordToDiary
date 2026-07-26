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

ActiveRecord::Schema[8.1].define(version: 2026_07_26_152140) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "diaries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "visibility", default: 2, null: false
    t.index ["user_id", "date"], name: "index_diaries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "diary_attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "diary_entry_id", null: false
    t.string "discord_attachment_id", null: false
    t.integer "position", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_entry_id", "position"], name: "index_diary_attachments_on_diary_entry_id_and_position", unique: true
    t.index ["diary_entry_id"], name: "index_diary_attachments_on_diary_entry_id"
    t.index ["discord_attachment_id"], name: "index_diary_attachments_on_discord_attachment_id", unique: true
  end

  create_table "diary_entries", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "diary_id", null: false
    t.string "discord_message_id", null: false
    t.datetime "posted_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_id"], name: "index_diary_entries_on_diary_id"
    t.index ["discord_message_id"], name: "index_diary_entries_on_discord_message_id", unique: true
  end

  create_table "discord_sync_states", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "last_discord_message_id"
    t.string "singleton_key", null: false
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["singleton_key"], name: "index_discord_sync_states_on_singleton_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.integer "default_visibility", default: 0, null: false
    t.string "discord_user_id", null: false
    t.string "discord_user_name", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_user_id"], name: "index_users_on_discord_user_id", unique: true
  end

  add_foreign_key "diaries", "users"
  add_foreign_key "diary_attachments", "diary_entries"
  add_foreign_key "diary_entries", "diaries"
end
