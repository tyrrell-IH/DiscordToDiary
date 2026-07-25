FactoryBot.define do
  factory :diary_attachment do
    diary_entry { nil }
    position { 1 }
    discord_attachment_id { "MyString" }
  end
end
