require "discordrb"

class MessageFetcher
  def initialize(last_discord_message_id: nil)
    @bot_token = Rails.application.credentials.fetch(:discord).fetch(:bot_token)
    @channel_id = Rails.application.credentials.fetch(:discord).fetch(:channel_id)
    @last_discord_message = last_discord_message_id
  end

  def call
    bot = Discordrb::Bot.new token: @bot_token
    channel = bot.channel @channel_id

    channel.history(100, nil, @last_discord_message_id)
  end
end
