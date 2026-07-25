require 'rails_helper'

RSpec.describe Diary, type: :model do
  it "destroys associated diary_entries when the diary is destroyed" do
    diary = FactoryBot.create(:diary)
    diary_entry = FactoryBot.create(:diary_entry, diary:)

    diary.destroy

    expect(DiaryEntry.exists?(diary_entry.id)).to be false
  end

  it "is invalid without a date" do
    diary = FactoryBot.build(:diary, date: nil)

    expect(diary).to be_invalid
  end

  it "is invalid with a duplicate date for same user" do
    user = FactoryBot.create(:user)
    date = Date.new(2026, 1, 1)

    FactoryBot.create(:diary, user:, date:)
    new_diary = FactoryBot.build(:diary, user:, date:)

    expect(new_diary).to be_invalid
    expect(new_diary.errors[:date]).to include("has already been taken")
  end

  it "is valid with the same date for a different user" do
    date = Date.new(2026, 1, 1)

    FactoryBot.create(:diary, date:)
    new_diary = FactoryBot.build(:diary, date:)

    expect(new_diary).to be_valid
  end

  it "is invalid without a visibility" do
    diary = FactoryBot.build(:diary, visibility: nil)

    expect(diary).to be_invalid
  end
end
