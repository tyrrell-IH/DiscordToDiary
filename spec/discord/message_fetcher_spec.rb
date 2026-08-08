require 'rails_helper'

RSpec.describe MessageFetcher do
  it "fetches messages across multiple pages" do
    bot = instance_double(Discordrb::Bot)
    channel = instance_double(Discordrb::Channel)

    allow(Discordrb::Bot).to receive(:new).and_return(bot)
    allow(bot).to receive(:channel).and_return(channel)

    newer_messages = [
      instance_double(Discordrb::Message, id: 5),
      instance_double(Discordrb::Message, id: 4),
      instance_double(Discordrb::Message, id: 3)
    ]

    older_messages = [
      instance_double(Discordrb::Message, id: 2),
      instance_double(Discordrb::Message, id: 1)
    ]

    expect(channel).to receive(:history).with(3, nil, nil).ordered.and_return(newer_messages)
    expect(channel).to receive(:history).with(3, 3, nil).ordered.and_return(older_messages)
    expect(channel).to receive(:history).with(3, 1, nil).ordered.and_return([])

    described_class.new.call(fetch_limit: 3)
  end
end
