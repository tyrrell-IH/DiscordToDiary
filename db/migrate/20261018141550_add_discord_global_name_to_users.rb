class AddDiscordGlobalNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :discord_global_name, :string
  end
end
