FactoryBot.define do
  factory :diary do
    date { "2026-07-20" }
    visibility { 1 }
    user { nil }
  end
end
