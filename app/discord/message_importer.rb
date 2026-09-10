class MessageImporter
  def initialize(message)
    @message = message
  end

  def call
    user = User.find_by(discord_user_id: @message.author.id)
    return unless user

    diary = user.diaries.find_or_create_by!(date: @message.timestamp.in_time_zone.to_date)
    diary.diary_entries.find_or_create_by!(discord_message_id: @message.id) do |entry|
      entry.content = @message.content
      entry.posted_at = @message.timestamp
    end
  end
end
