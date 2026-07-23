FactoryBot.define do
  factory :diary_entry do
    diary { nil }
    content { "MyText" }
    posted_at { "2026-07-22 14:45:51" }
    discord_message_id { "MyString" }
  end
end
