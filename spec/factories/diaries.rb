FactoryBot.define do
  factory :diary do
    sequence(:date) { |n| Date.new(2026, 1, 1) + (n - 1).days }
    visibility { :only_me }
    association :user
  end
end
