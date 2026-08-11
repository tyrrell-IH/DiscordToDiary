require "discordrb"

class MessageFetcher
  FETCH_LIMIT = 100

  def initialize(last_discord_message_id: nil)
    @bot_token = Rails.application.credentials.fetch(:discord).fetch(:bot_token)
    @channel_id = Rails.application.credentials.fetch(:discord).fetch(:channel_id)
    @last_discord_message_id = last_discord_message_id
  end

  def call(fetch_limit: FETCH_LIMIT)
    bot = Discordrb::Bot.new token: @bot_token
    channel = bot.channel @channel_id

    all_messages = []
    before_id = nil
    checkpoint = @last_discord_message_id&.to_i

    loop do
      messages = channel.history(fetch_limit, before_id)
      break if messages.empty?

      if checkpoint
        all_messages.concat(messages.select { |message| message.id > checkpoint })
        break if messages.any? { |message| message.id <= checkpoint }
      else
        all_messages.concat(messages)
      end

      before_id = messages.last.id
    end

    all_messages
  end
end
