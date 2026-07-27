class CreateDiaryAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :diary_attachments do |t|
      t.references :diary_entry, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :discord_attachment_id, null: false

      t.timestamps
    end

    add_index :diary_attachments, [ :diary_entry_id, :position ], unique: true
    add_index :diary_attachments, :discord_attachment_id, unique: true
  end
end
