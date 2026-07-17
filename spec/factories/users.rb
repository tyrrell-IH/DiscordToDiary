FactoryBot.define do
  factory :user do
    discord_user_name { "MyString" }
    discord_user_id { "MyString" }
    avatar_url { "MyString" }
    default_visibility { 1 }
  end
end
