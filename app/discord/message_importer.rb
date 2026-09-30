require "open-uri"
require "stringio"

class MessageImporter
  def initialize(message)
    @message = message
  end

  def call
    user = User.find_by(discord_user_id: @message.author.id)
    return unless user

    ActiveRecord::Base.transaction do
      diary = user.diaries.find_or_create_by!(date: @message.timestamp.in_time_zone.to_date)
      entry = diary.diary_entries.find_or_create_by!(discord_message_id: @message.id) do |entry|
        entry.content = @message.content
        entry.posted_at = @message.timestamp
      end

      import_attachments(entry)
    end
  end

  private

  def import_attachments(entry)
    @message.attachments.each_with_index do |attachment, i|
      diary_attachment = entry.diary_attachments.find_or_create_by!(discord_attachment_id: attachment.id.to_s) do |record|
        record.position = i
      end

      next if diary_attachment.file.attached?

      image_data = URI.open(attachment.url) { |file| file.read }
      image_io = StringIO.new(image_data)

      blob = ActiveStorage::Blob.create_and_upload!(
        io: image_io,
        filename: attachment.filename,
        content_type: attachment.content_type
      )

      diary_attachment.file.attach(blob)
    end
  end
end
