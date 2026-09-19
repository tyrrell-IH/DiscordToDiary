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
  let(:messages) { [ newer_message, older_message ] }
  let(:fetcher) { instance_double(MessageFetcher, call: messages) }

  before do
    allow(MessageFetcher).to receive(:new).and_return(fetcher)

    FactoryBot.create(
      :user,
      discord_user_id: author.id.to_s)
  end

  it "imports messages and updates the last Discord message ID" do
    expect {
      described_class.new.call
    }.to change(Diary, :count).by(1)
                              .and change(DiaryEntry, :count).by(2)

    sync_state = DiscordSyncState.find_by!(singleton_key: DiscordSyncState::SINGLETON_KEY)
    expect(sync_state.last_discord_message_id).to eq("2")
  end

  context "when updating the last Discord message ID fails" do
    let(:sync_state) do
      FactoryBot.create(:discord_sync_state, last_discord_message_id: nil)
    end

    before do
      allow(DiscordSyncState)
        .to receive(:find_or_create_by!)
              .with(singleton_key: DiscordSyncState::SINGLETON_KEY)
              .and_return(sync_state)

      allow(sync_state)
        .to receive(:update!)
              .with(last_discord_message_id: older_message.id)
              .and_raise(ActiveRecord::RecordInvalid.new(sync_state))
    end

    it "rolls back the diary and diary entry creation" do
      expect {
        described_class.new.call
      }.to raise_error(ActiveRecord::RecordInvalid)
             .and change(Diary, :count).by(0)
                                        .and change(DiaryEntry, :count).by(0)

      expect(sync_state.reload.last_discord_message_id).to be_nil
    end
  end
end
