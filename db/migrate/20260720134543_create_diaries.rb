class CreateDiaries < ActiveRecord::Migration[8.1]
  def change
    create_table :diaries do |t|
      t.date :date, null: false
      t.integer :visibility, null: false, default: 2
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :diaries, [ :user_id, :date ], unique: true
  end
end
