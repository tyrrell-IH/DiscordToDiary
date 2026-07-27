class DiaryAttachment < ApplicationRecord
  belongs_to :diary_entry

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            uniqueness: { scope: :diary_entry_id }
  validates :discord_attachment_id, presence: true, uniqueness: true
end
