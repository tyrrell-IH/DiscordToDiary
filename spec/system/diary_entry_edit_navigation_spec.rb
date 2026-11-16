require 'rails_helper'

RSpec.describe "Diary entry edit navigation", type: :system do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary) { FactoryBot.create(:diary,
                                   user: diary_owner,
                                   visibility: "everyone",
                                   date: Date.new(2026, 1, 1)) }
  let!(:entry) { FactoryBot.create(:diary_entry,
                                         diary: diary) }
  let(:auth_info) do
    OmniAuth::AuthHash.new(
      provider: "discord",
      uid: diary_owner.discord_user_id,
      info: {
        name: diary_owner.discord_user_name,
        image: diary_owner.avatar_url
      },
      extra: {
        raw_info: {
          global_name: diary_owner.discord_global_name
        }
      }
    )
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:discord] = auth_info
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:discord] = nil
  end

  it "opens the entry edit page when the edit link is clicked" do
    visit "/auth/discord/callback"
    visit diary_path(diary)

    click_link "編集"

    expect(page).to have_current_path(edit_diary_entry_path(entry))
    expect(page).to have_css("h1", text: "diary_entries#edit")
  end
end
