class Diary < ApplicationRecord
  belongs_to :user

  enum :visibility, { everyone: 0, members_only: 1, only_me: 2 }

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :visibility, presence: true
end
