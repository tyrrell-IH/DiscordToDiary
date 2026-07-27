class DiscordSyncState < ApplicationRecord
  SINGLETON_KEY = "discord_sync_state"

  validates :singleton_key,
            presence: true,
            uniqueness: true,
            inclusion: { in: [ SINGLETON_KEY ] }
end
