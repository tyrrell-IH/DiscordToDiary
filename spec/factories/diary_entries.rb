FactoryBot.define do
  factory :diary_entry do
    association :diary
    content { "sample text" }
    posted_at { diary.date.in_time_zone }
    sequence(:discord_message_id) { |n| "123456789012345678#{n}" }
  end
end
