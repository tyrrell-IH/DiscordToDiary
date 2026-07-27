class CreateDiaryEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :diary_entries do |t|
      t.references :diary, null: false, foreign_key: true
      t.text :content, null: false
      t.datetime :posted_at, null: false
      t.string :discord_message_id, null: false

      t.timestamps
    end

    add_index :diary_entries, :discord_message_id, unique: true
  end
end
