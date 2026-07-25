require 'rails_helper'

RSpec.describe DiaryAttachment, type: :model do
  it "is invalid without a position" do
    diary_attachment = FactoryBot.build(:diary_attachment, position: nil)

    expect(diary_attachment).to be_invalid
  end

  it "is invalid with a duplicate position for same diary_entry" do
    diary_entry = FactoryBot.create(:diary_entry)
    FactoryBot.create(:diary_attachment, diary_entry:, position: 0)

    new_diary_attachment = FactoryBot.build(:diary_attachment, diary_entry:, position: 0)

    expect(new_diary_attachment).to be_invalid
    expect(new_diary_attachment.errors[:position]).to include("has already been taken")
  end

  it "is invalid with a negative position" do
    diary_attachment = FactoryBot.build(:diary_attachment, position: -1)

    expect(diary_attachment).to be_invalid
  end

  it "is valid with position 0" do
    diary_attachment = FactoryBot.build(:diary_attachment, position: 0)

    expect(diary_attachment).to be_valid
  end

  it "is invalid without a discord_attachment_id" do
    diary_attachment = FactoryBot.build(:diary_attachment, discord_attachment_id: nil)

    expect(diary_attachment).to be_invalid
  end

  it "is invalid with a duplicate discord_attachment_id" do
    FactoryBot.create(:diary_attachment, discord_attachment_id: "123")

    new_diary_attachment = FactoryBot.build(:diary_attachment, discord_attachment_id: "123")

    expect(new_diary_attachment).to be_invalid
    expect(new_diary_attachment.errors[:discord_attachment_id]).to include("has already been taken")
  end
end
