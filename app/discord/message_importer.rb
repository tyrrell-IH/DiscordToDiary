require "open-uri"

class MessageImporter
  def initialize(message)
    @message = message
  end

  def import(user, attachment_blob_pairs)
    ActiveRecord::Base.transaction do
      diary = user.diaries.find_or_create_by!(date: @message.timestamp.in_time_zone.to_date)
      entry = diary.diary_entries.find_or_create_by!(discord_message_id: @message.id.to_s) do |entry|
        entry.content = @message.content
        entry.posted_at = @message.timestamp
      end

      attachment_blob_pairs.each_with_index do |pair, position|
        attachment = pair[:attachment]
        blob = pair[:blob]

        record = entry.diary_attachments.find_or_create_by!(discord_attachment_id: attachment.id.to_s) do |diary_attachment|
          diary_attachment.position = position
        end

        record.file.attach(blob)
      end
    end
  end

  def upload_attachments
    blobs = []
    @message.attachments.map do |attachment|
      begin
        blob = URI.open(attachment.url) do |file|
          ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: attachment.filename,
            content_type: attachment.content_type
          )
        end

      rescue StandardError
        blobs.each(&:purge)
        raise
      end

      blobs << blob

      { attachment: attachment, blob: blob }
    end
  end

  def imported?
    DiaryEntry.exists?(discord_message_id: @message.id)
  end
end
