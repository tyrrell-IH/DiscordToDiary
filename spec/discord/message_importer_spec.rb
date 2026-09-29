require 'rails_helper'
require 'discordrb'

RSpec.describe MessageImporter do
  describe "#call" do
    let(:author) { instance_double(Discordrb::Member, id: 12345) }
    let(:attachment) { instance_double(
      Discordrb::Attachment,
      id: 12345,
      url: "https://sample/attachments/abcd1234",
      filename: "sample.jpeg",
      content_type: "image/jpeg"
    ) }
    let(:message) do
      instance_double(
        Discordrb::Message,
        author: author,
        timestamp: Time.utc(2026, 1, 1, 16, 0, 0),
        id: 678910,
        content: "test",
        attachments: [ attachment ]
      )
    end
    let(:file) { instance_double(IO, read: "dummy") }

    before do
      allow(URI).to receive(:open).with(attachment.url).and_yield(file)
    end

    context "when the message author is registered" do
      before do
        FactoryBot.create(
          :user,
          discord_user_id: author.id.to_s)
      end

      it "creates a diary, a diary entry, and an attachment file" do
        expect {
          described_class.new(message).call
        }.to change(Diary, :count).by(1)
                                  .and change(DiaryEntry, :count).by(1)
                                                                 .and change(DiaryAttachment, :count).by(1)

        entry = DiaryEntry.find_by!(discord_message_id: message.id)
        expect(entry).to have_attributes(
                           content: message.content,
                           posted_at: message.timestamp
                         )
        expect(entry.diary_attachments.first.file).to be_attached
      end

      it "uses the Tokyo time zone to determine the diary date" do
        described_class.new(message).call
        diary = DiaryEntry.find_by!(discord_message_id: message.id).diary

        expect(diary.date).to eq(Date.new(2026, 1, 2))
      end

      it "does not import the same message twice" do
        described_class.new(message).call

        expect {
          described_class.new(message).call
        }.to_not change { [ Diary.count, DiaryEntry.count ] }
      end

      context "when creating the diary entry fails" do
        let(:invalid_message) do
          instance_double(Discordrb::Message,
                          author: author,
                          timestamp: Time.utc(2026, 1, 1, 1, 0, 0),
                          id: nil,
                          content: "test")
        end

        it "rolls back the diary creation" do
          expect {
            described_class.new(invalid_message).call
          }.to raise_error(ActiveRecord::RecordInvalid)
                 .and change(Diary, :count).by(0)
                                           .and change(DiaryEntry, :count).by(0)
        end
      end
    end

    context "when the message author is not registered" do
      it "does not save messages to the database" do
        expect {
          described_class.new(message).call
        }.to_not change { [ Diary.count, DiaryEntry.count ] }
      end
    end
  end
end
