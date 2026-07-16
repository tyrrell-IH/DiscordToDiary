FactoryBot.define do
  factory :user do
    discord_user_name { "tyrrell" }
    discord_user_id { "123456789012345678" }
    avatar_url { "https://example.com/avatar.png" }
    default_visibility { :everyone }
  end
end
