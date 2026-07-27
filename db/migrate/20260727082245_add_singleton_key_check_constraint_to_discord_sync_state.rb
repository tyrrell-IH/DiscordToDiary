class AddSingletonKeyCheckConstraintToDiscordSyncState < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :discord_sync_states,
                         "singleton_key = 'discord_sync_state'",
                         name: "discord_sync_states_singleton_key_check"
  end
end
