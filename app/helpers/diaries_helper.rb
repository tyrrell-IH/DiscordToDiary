module DiariesHelper
  def discord_message_url(entry)
    server_id = Rails.application.credentials.fetch(:discord).fetch(:server_id)
    channel_id = Rails.application.credentials.fetch(:discord).fetch(:channel_id)

    "https://discord.com/channels/#{server_id}/#{channel_id}/#{entry.discord_message_id}"
  end
end
