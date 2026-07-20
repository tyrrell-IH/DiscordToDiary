FactoryBot.define do
  factory :user do
    sequence(:discord_user_name) { |n| "user#{n}" }
    sequence(:discord_user_id) { |n| "123456789012345678#{n}" }
    avatar_url { "https://example.com/avatar.png" }
    default_visibility { :everyone }
  end
end
