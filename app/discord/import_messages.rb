class ImportMessages
  def call
    sync_state = DiscordSyncState.find_or_create_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
    messages = MessageFetcher.new(last_discord_message_id: sync_state.last_discord_message_id).call

    messages.sort_by(&:id).each do |message|
      ActiveRecord::Base.transaction do
        MessageImporter.new(message).call
        sync_state.update!(last_discord_message_id: message.id)
      end
    end
  end
end
