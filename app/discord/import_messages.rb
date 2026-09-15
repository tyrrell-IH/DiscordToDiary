class ImportMessages
  def call
    messages = MessageFetcher.new.call

    messages.each do |message|
      MessageImporter.new(message).call
    end
  end
end
