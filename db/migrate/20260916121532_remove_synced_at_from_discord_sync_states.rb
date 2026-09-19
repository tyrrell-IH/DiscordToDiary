class RemoveSyncedAtFromDiscordSyncStates < ActiveRecord::Migration[8.1]
  def change
    remove_column :discord_sync_states, :synced_at, :datetime
  end
end
