require 'rails_helper'
require 'discordrb'
require "open-uri"

RSpec.describe ImportMessages do
  let(:author) { instance_double(Discordrb::Member, id: 12345) }
  let(:attachment) { instance_double(
    Discordrb::Attachment,
    id: 12345,
    url: "https://sample/attachments/abcd1234",
    filename: "attachment",
    content_type: "image/jpeg"
  ) }
  let(:older_message) do
    instance_double(
      Discordrb::Message,
      author: author,
      timestamp: Time.utc(2026, 1, 1, 1, 0, 0),
      id: 1,
      content: "1回目の投稿",
      attachments: [ attachment ]
    )
  end
  let(:newer_message) do
    instance_double(
      Discordrb::Message,
      author: author,
      timestamp: Time.utc(2026, 1, 1, 2, 0, 0),
      id: 2,
      content: "2回目の投稿",
      attachments: []
    )
  end
  let(:messages) { [ newer_message, older_message ] }
  let(:fetcher) { instance_double(MessageFetcher, call: messages) }
  let(:file) { instance_double(IO, read: "dummy") }

  before do
    allow(MessageFetcher).to receive(:new).and_return(fetcher)
    allow(URI).to receive(:open).with(attachment.url).and_yield(file)

    FactoryBot.create(
      :user,
      discord_user_id: author.id.to_s
    )
  end

  describe "#call" do
    it "uploads attachments, imports messages and updates the last discord message id" do
      expect {
        described_class.new.call
      }.to change(Diary, :count).by(1)
                                .and change(DiaryEntry, :count).by(2)
                                                               .and change(DiaryAttachment, :count).by(1)

      record = DiaryAttachment.find_by!(discord_attachment_id: attachment.id.to_s)
      expect(record.file.download).to eq("dummy")

      sync_state = DiscordSyncState.find_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
      expect(sync_state.last_discord_message_id).to eq("2")
    end

    context "when the message author is not registered" do
      let(:unregistered_author) { instance_double(Discordrb::Member, id: 9999) }
      let(:message) do
        instance_double(
          Discordrb::Message,
          author: unregistered_author,
          timestamp: Time.utc(2026, 1, 1, 3, 0, 0),
          id: 3,
          content: "登録されていないユーザーの投稿",
          attachments: []
        )
      end
      let(:messages) { [ message ] }

      it "does not save messages and updates the sync state" do
        expect {
          described_class.new.call
        }.not_to change { [ Diary.count, DiaryEntry.count, DiaryAttachment.count ] }

        sync_state = DiscordSyncState.find_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
        expect(sync_state.last_discord_message_id).to eq("3")
      end
    end

    context "when the message has already been imported" do
      before do
        FactoryBot.create(:diary_entry, discord_message_id: newer_message.id.to_s)
      end

      context "when the message ID newer than sync state" do
        let(:messages) { [ newer_message ] }
        before do
          FactoryBot.create(:discord_sync_state, last_discord_message_id: 1)
        end

        it "does not save messages and updates the sync state" do
          expect {
            described_class.new.call
          }.not_to change { [ Diary.count, DiaryEntry.count, DiaryAttachment.count ] }

          sync_state = DiscordSyncState.find_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
          expect(sync_state.last_discord_message_id).to eq("2")
        end
      end

      context "when the message ID older than sync state" do
        let(:messages) { [ newer_message ] }
        before do
          FactoryBot.create(:discord_sync_state, last_discord_message_id: 4)
        end

        it "does not save messages and does not update the sync state" do
          expect {
            described_class.new.call
          }.not_to change { [ Diary.count, DiaryEntry.count, DiaryAttachment.count ] }

          sync_state = DiscordSyncState.find_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
          expect(sync_state.last_discord_message_id).to eq("4")
        end
      end
    end

    context "when a failure occurs within a transaction" do
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("dummy"),
          filename: attachment.filename,
          content_type: attachment.content_type
        )
      end
      let(:attachment_blob_pairs) { [ { attachment: attachment, blob: blob } ] }
      let(:importer) { instance_double(
        MessageImporter,
        upload_attachments: attachment_blob_pairs,
        imported?: false
      ) }
      let(:messages) { [ older_message ] }
      before do
        allow(MessageImporter).to receive(:new).with(older_message).and_return(importer)
      end

      context "when the import fails" do
        before do
          allow(importer)
            .to receive(:import)
                  .with(instance_of(User), attachment_blob_pairs)
                  .and_raise(StandardError, "Import Fails")
        end

        it "deletes the blob and the uploaded files" do
          blob_id = blob.id
          service = blob.service
          key = blob.key

          expect(Rails.logger).to receive(:error).with(
            a_string_including(
              "message_id=#{older_message.id} ",
              "StandardError: Import Fails"
            )
          )

          expect {
            described_class.new.call
          }.to raise_error(StandardError, "Import Fails")

          expect(ActiveStorage::Blob.exists?(blob_id)).to be false
          expect(service.exist?(key)).to be false
        end
      end
      context "when updating the sync state fails" do
        let(:sync_state) { instance_double(DiscordSyncState, last_discord_message_id: nil) }
        before do
          allow(importer)
            .to receive(:import)
                  .with(instance_of(User), attachment_blob_pairs)
                  .and_return(nil)
          allow(DiscordSyncState)
            .to receive(:find_or_create_by!)
                  .with(singleton_key: DiscordSyncState::SINGLETON_KEY)
                  .and_return(sync_state)
          allow(sync_state)
            .to receive(:update!)
                  .with(last_discord_message_id: older_message.id)
                  .and_raise(StandardError, "Update Sync State Fails")
        end

        it "deletes the blob and the uploaded files" do
          blob_id = blob.id
          service = blob.service
          key = blob.key

          expect(Rails.logger).to receive(:error).with(
            a_string_including(
              "message_id=#{older_message.id} ",
              "StandardError: Update Sync State Fails"
            )
          )

          expect {
            described_class.new.call
          }.to raise_error(StandardError, "Update Sync State Fails")

          expect(ActiveStorage::Blob.exists?(blob_id)).to be false
          expect(service.exist?(key)).to be false
        end
      end
    end
  end
end
