require 'rails_helper'

RSpec.describe DiaryEntry, type: :model do
  it "destroys associated diary_attachment when the diary_entry is destroyed" do
    diary_entry = FactoryBot.create(:diary_entry)
    diary_attachment = FactoryBot.create(:diary_attachment, diary_entry:)

    diary_entry.destroy

    expect(DiaryAttachment.exists?(diary_attachment.id)).to be false
  end

  it "is invalid without a posted_at" do
    diary_entry = FactoryBot.build(:diary_entry, posted_at: nil)

    expect(diary_entry).to be_invalid
  end

  it "is invalid without a discord_message_id" do
    diary_entry = FactoryBot.build(:diary_entry, discord_message_id: nil)

    expect(diary_entry).to be_invalid
  end

  it "is invalid with a duplicate discord_message_id" do
    FactoryBot.create(:diary_entry, discord_message_id: "123")
    new_diary_entry = FactoryBot.build(:diary_entry, discord_message_id: "123")

    expect(new_diary_entry).to be_invalid
    expect(new_diary_entry.errors[:discord_message_id]).to include("has already been taken")
  end
end
