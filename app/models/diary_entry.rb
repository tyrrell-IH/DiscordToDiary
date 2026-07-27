class DiaryEntry < ApplicationRecord
  belongs_to :diary
  has_many :diary_attachments, dependent: :destroy

  validates :posted_at, presence: true
  validates :discord_message_id, presence: true, uniqueness: true
end
