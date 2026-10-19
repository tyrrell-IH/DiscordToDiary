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

ActiveRecord::Schema[8.1].define(version: 2026_10_18_141550) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "diaries", force: :cascade do |t|
    t.date "date", null: false
    t.integer "visibility", default: 2, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "date"], name: "index_diaries_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "diary_attachments", force: :cascade do |t|
    t.bigint "diary_entry_id", null: false
    t.integer "position", null: false
    t.string "discord_attachment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_entry_id", "position"], name: "index_diary_attachments_on_diary_entry_id_and_position", unique: true
    t.index ["diary_entry_id"], name: "index_diary_attachments_on_diary_entry_id"
    t.index ["discord_attachment_id"], name: "index_diary_attachments_on_discord_attachment_id", unique: true
  end

  create_table "diary_entries", force: :cascade do |t|
    t.bigint "diary_id", null: false
    t.text "content", null: false
    t.datetime "posted_at", null: false
    t.string "discord_message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_id"], name: "index_diary_entries_on_diary_id"
    t.index ["discord_message_id"], name: "index_diary_entries_on_discord_message_id", unique: true
  end

  create_table "discord_sync_states", force: :cascade do |t|
    t.string "last_discord_message_id"
    t.string "singleton_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["singleton_key"], name: "index_discord_sync_states_on_singleton_key", unique: true
    t.check_constraint "singleton_key::text = 'discord_sync_state'::text", name: "discord_sync_states_singleton_key_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.integer "default_visibility", default: 0, null: false
    t.string "discord_user_id", null: false
    t.string "discord_user_name", null: false
    t.datetime "updated_at", null: false
    t.string "discord_global_name"
    t.index ["discord_user_id"], name: "index_users_on_discord_user_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "diaries", "users"
  add_foreign_key "diary_attachments", "diary_entries"
  add_foreign_key "diary_entries", "diaries"
end
