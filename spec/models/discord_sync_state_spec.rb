require 'rails_helper'

RSpec.describe DiscordSyncState, type: :model do
  it "is invalid without a singleton_key" do
    discord_sync_state = FactoryBot.build(:discord_sync_state, singleton_key: nil)

    expect(discord_sync_state).to be_invalid
  end

  it "is invalid with a duplicate singleton_key" do
    FactoryBot.create(:discord_sync_state)

    new_discord_sync_state = FactoryBot.build(:discord_sync_state)

    expect(new_discord_sync_state).to be_invalid
    expect(new_discord_sync_state.errors[:singleton_key]).to include("has already been taken")
  end
end
