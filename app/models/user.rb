class User < ApplicationRecord
  enum :default_visibility, { unconfigured: 0, everyone: 1, members_only: 2, only_me: 3 }

  validates :discord_user_name, presence: true
  validates :discord_user_id, presence: true, uniqueness: true
  validates :default_visibility, presence: true
end
