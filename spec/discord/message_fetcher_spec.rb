require 'rails_helper'

RSpec.describe MessageFetcher do
  let(:bot) { instance_double(Discordrb::Bot) }
  let(:channel) { instance_double(Discordrb::Channel) }
  let(:newer_messages) do
    [
      instance_double(Discordrb::Message, id: 5),
      instance_double(Discordrb::Message, id: 4),
      instance_double(Discordrb::Message, id: 3)
    ]
  end
  let(:older_messages) do
    [
      instance_double(Discordrb::Message, id: 2),
      instance_double(Discordrb::Message, id: 1)
    ]
  end

  before do
    allow(Discordrb::Bot).to receive(:new).and_return(bot)
    allow(bot).to receive(:channel).and_return(channel)
    allow(Rails.application.credentials).to receive(:fetch)
                                              .with(:discord)
                                              .and_return({ bot_token: "test-token", channel_id: 123 })
  end

  describe "#call" do
    context "when the last discord message id is nil" do
      let(:last_discord_message_id) { nil }

      it "fetches messages across multiple pages" do
        expect(channel).to receive(:history).with(3, nil).ordered.and_return(newer_messages)
        expect(channel).to receive(:history).with(3, 3).ordered.and_return(older_messages)
        expect(channel).to receive(:history).with(3, 1).ordered.and_return([])

        result = described_class.new(last_discord_message_id:).call(fetch_limit: 3)
        expect(result.map(&:id)).to eq([ 5, 4, 3, 2, 1 ])
      end
    end

    context "when the last discord message id is present" do
      let(:last_discord_message_id) { 1 }

      it "fetches only messages newer than the checkpoint" do
        expect(channel).to receive(:history).with(3, nil).ordered.and_return(newer_messages)
        expect(channel).to receive(:history).with(3, 3).ordered.and_return(older_messages)

        result = described_class.new(last_discord_message_id:).call(fetch_limit: 3)
        expect(result.map(&:id)).to eq([ 5, 4, 3, 2 ])
      end
    end
  end
end
