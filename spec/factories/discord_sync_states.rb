FactoryBot.define do
  factory :discord_sync_state do
    last_discord_message_id { "MyString" }
    synced_at { "2026-07-27 00:21:40" }
    singleton_key { "MyString" }
  end
end
