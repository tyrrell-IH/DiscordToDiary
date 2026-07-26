class CreateDiscordSyncStates < ActiveRecord::Migration[8.1]
  def change
    create_table :discord_sync_states do |t|
      t.string :last_discord_message_id
      t.datetime :synced_at
      t.string :singleton_key, null: false

      t.timestamps
    end

    add_index :discord_sync_states, :singleton_key, unique: true
  end
end
