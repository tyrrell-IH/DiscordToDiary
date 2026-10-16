require 'rails_helper'
require 'discordrb'
require "stringio"

RSpec.describe MessageImporter do
  let(:user) { FactoryBot.create(:user) }
  let(:attachment1) { instance_double(
    Discordrb::Attachment,
    id: 123,
    url: "https://sample/attachments/123",
    filename: "attachment1",
    content_type: "image/jpeg"
  ) }
  let(:attachment2) { instance_double(
    Discordrb::Attachment,
    id: 456,
    url: "https://sample/attachments/456",
    filename: "attachment2",
    content_type: "image/jpeg"
  ) }
  let(:message) do
    instance_double(
      Discordrb::Message,
      timestamp: Time.utc(2026, 1, 1, 16, 0, 0),
      id: 678910,
      content: "test",
      attachments: [ attachment1, attachment2 ]
    )
  end
  let(:file1) { StringIO.new("dummy1") }
  let(:file2) { StringIO.new("dummy2") }
  let(:importer) { described_class.new(message) }
  let(:attachment_blob_pairs) { importer.upload_attachments }

  before do
    allow(URI).to receive(:open).with(attachment1.url).and_yield(file1)
    allow(URI).to receive(:open).with(attachment2.url).and_yield(file2)
  end

  describe "#import" do
    it "creates a diary, a diary entry, and attaches uploaded files" do
      expect {
        importer.import(user, attachment_blob_pairs)
      }.to change(Diary, :count).by(1)
                                .and change(DiaryEntry, :count).by(1)
                                                               .and change(DiaryAttachment, :count).by(2)

      entry = DiaryEntry.find_by!(discord_message_id: message.id)
      expect(entry).to have_attributes(
                         content: message.content,
                         posted_at: message.timestamp
                       )
      attachment_blob_pairs.each do |pair|
        attachment = entry.diary_attachments.find_by!(discord_attachment_id: pair[:attachment].id.to_s)
        expect(attachment.file.blob).to eq(pair[:blob])
      end
    end

    it "uses the Tokyo time zone to determine the diary date" do
      importer.import(user, attachment_blob_pairs)
      diary = DiaryEntry.find_by!(discord_message_id: message.id).diary

      expect(diary.date).to eq(Date.new(2026, 1, 2))
    end

    context "when attachment fails" do
      before do
        allow_any_instance_of(ActiveStorage::Attached::One)
          .to receive(:attach)
                .and_raise(StandardError, "Attachment failed")
      end

      it "rolls back the diary, the diary entry and the attachment creation" do
        expect {
          importer.import(user, attachment_blob_pairs)
        }.to raise_error(StandardError, "Attachment failed")
               .and change(Diary, :count).by(0)
                                         .and change(DiaryEntry, :count).by(0)
                                                                        .and change(DiaryAttachment, :count).by(0)
      end
    end
  end

  describe "#upload_attachments" do
    it "uploads attachments and returns attachment-blob pairs" do
      pairs = importer.upload_attachments

      expect(pairs.size).to eq(2)

      expect(pairs.first[:attachment]).to eq(attachment1)
      expect(pairs.first[:blob].filename).to eq(attachment1.filename)
      expect(pairs.first[:blob].download).to eq("dummy1")

      expect(pairs.last[:attachment]).to eq(attachment2)
      expect(pairs.last[:blob].filename).to eq(attachment2.filename)
      expect(pairs.last[:blob].download).to eq("dummy2")
    end

    context "when downloading the second attachment fails" do
      let!(:uploaded_blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("dummy1"),
          filename: attachment1.filename,
          content_type: attachment1.content_type
        )
      end

      before do
        allow(URI).to receive(:open).with(attachment2.url).and_raise(StandardError, "The second attachment failed")
        allow(ActiveStorage::Blob).to receive(:create_and_upload!).and_return(uploaded_blob)
      end

      it "deletes the previously uploaded blob and file" do
        blob_id = uploaded_blob.id
        service = uploaded_blob.service
        key = uploaded_blob.key

        expect {
          importer.upload_attachments
        }.to raise_error(StandardError, "The second attachment failed")

        expect(ActiveStorage::Blob.exists?(blob_id)).to be false
        expect(service.exist?(key)).to be false
      end
    end
  end

  describe "#imported?" do
    context "when the message has been imported" do
      it "returns true" do
        importer.import(user, attachment_blob_pairs)

        expect(importer.imported?).to be true
      end
    end

    context "when the message has not been imported" do
      it "returns false" do
        expect(importer.imported?).to be false
      end
    end
  end
end
