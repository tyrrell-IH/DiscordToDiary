FactoryBot.define do
  factory :diary_attachment do
    association :diary_entry
    position { 0 }
    sequence(:discord_attachment_id) { |n| "123456789012345678#{n}" }
  end
end
