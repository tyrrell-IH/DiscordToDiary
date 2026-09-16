require 'rails_helper'
require 'discordrb'

RSpec.describe MessageImporter do
  describe "#call" do
    let(:author) { instance_double(Discordrb::Member, id: 12345) }
    let(:message) do
      instance_double(Discordrb::Message,
                      author: author,
                      timestamp: Time.utc(2026, 1, 1, 16, 0, 0),
                      id: 678910,
                      content: "test")
    end

    context "when the message author is registered" do
      before do
        FactoryBot.create(
          :user,
          discord_user_id: author.id.to_s)
      end

      it "creates a diary and a diary entry" do
        expect {
          described_class.new(message).call
        }.to change(Diary, :count).by(1)
                                  .and change(DiaryEntry, :count).by(1)

        entry = DiaryEntry.find_by!(discord_message_id: message.id)
        expect(entry).to have_attributes(
                           content: message.content,
                           posted_at: message.timestamp
                         )
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
