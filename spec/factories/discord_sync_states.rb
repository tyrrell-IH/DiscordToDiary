FactoryBot.define do
  factory :discord_sync_state do
    last_discord_message_id { "1234567890123456789" }
    synced_at { Time.current }
    singleton_key { DiscordSyncState::SINGLETON_KEY }
  end
end
