class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :discord_user_name, null: false
      t.string :discord_user_id, null: false
      t.string :avatar_url
      t.integer :default_visibility, null: false, default: 2
      t.boolean :default_visibility_configured, null: false, default: false

      t.timestamps
    end

    add_index :users, :discord_user_id, unique: true
  end
end
