require 'rails_helper'

RSpec.describe "Diary entry edit navigation", type: :system do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary) { FactoryBot.create(:diary,
                                   user: diary_owner,
                                   visibility: "everyone",
                                   date: Date.new(2026, 1, 1)) }
  let!(:entry) { FactoryBot.create(:diary_entry,
                                         diary: diary) }
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:discord] = nil
  end

  it "opens the entry edit page when the edit link is clicked" do
    log_in_as(diary_owner)
    visit diary_path(diary)

    click_link "編集"

    expect(page).to have_current_path(edit_diary_entry_path(entry))
    expect(page).to have_css("h1.diary-entry-edit-title", text: "投稿を編集")
  end
end
