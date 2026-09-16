require 'rails_helper'
require 'discordrb'

RSpec.describe ImportMessages do
  let(:author) { instance_double(Discordrb::Member, id: 12345) }
  let(:older_message) do
    instance_double(Discordrb::Message,
                    author: author,
                    timestamp: Time.utc(2026, 1, 1, 1, 0, 0),
                    id: 1,
                    content: "1回目の投稿")
  end
  let(:newer_message) do
    instance_double(Discordrb::Message,
                    author: author,
                    timestamp: Time.utc(2026, 1, 1, 2, 0, 0),
                    id: 2,
                    content: "2回目の投稿")
  end
  let(:messages) { [ older_message, newer_message ] }
  let(:fetcher) { instance_double(MessageFetcher, call: messages) }

  before do
    allow(MessageFetcher).to receive(:new).and_return(fetcher)

    FactoryBot.create(
      :user,
      discord_user_id: author.id.to_s)
  end

  it "fetches messages and imports them into the database" do
    expect {
      described_class.new.call
    }.to change(Diary, :count).by(1)
                              .and change(DiaryEntry, :count).by(2)
  end
end
