class ImportMessages
  def call
    sync_state = DiscordSyncState.find_or_create_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
    messages = MessageFetcher.new(last_discord_message_id: sync_state.last_discord_message_id).call

    messages.sort_by(&:id).each do |message|
      begin
        user = User.find_by(discord_user_id: message.author.id)

        unless user
          sync_state.update!(last_discord_message_id: message.id)
          next
        end

        importer = MessageImporter.new(message)
        if importer.imported?
          if message.id > sync_state.last_discord_message_id.to_i
            sync_state.update!(last_discord_message_id: message.id)
          end

          next
        end

        attachment_blob_pairs = importer.upload_attachments

        ActiveRecord::Base.transaction do |transaction|
          transaction.after_rollback do
            attachment_blob_pairs.each do |pair|
              pair[:blob].purge
            end
          end

          importer.import(user, attachment_blob_pairs)
          sync_state.update!(last_discord_message_id: message.id)
        end
      rescue StandardError => error
        Rails.logger.error(
          "Discordメッセージの取り込み失敗 " \
            "message_id=#{message.id} " \
            "#{error.class}: #{error.message}"
        )
        raise
      end
    end
  end
end
