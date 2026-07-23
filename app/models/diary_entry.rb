class DiaryEntry < ApplicationRecord
  belongs_to :diary

  validates :posted_at, presence: true
  validates :discord_message_id, presence: true, uniqueness: true
end
