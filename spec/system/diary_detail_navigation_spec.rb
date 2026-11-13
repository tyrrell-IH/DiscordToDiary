require 'rails_helper'

RSpec.describe "Diary detail navigation", type: :system do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary) { FactoryBot.create(:diary,
                                    user: diary_owner,
                                    visibility: "everyone",
                                    date: Date.new(2026, 1, 1)) }

  it "shows diary details when the date link is clicked" do
    visit user_diaries_path(diary_owner)

    expect(page).to have_content("2026年1月分の日記")
    expect(page).to have_content("2026年1月1日")

    click_link "2026年1月1日"

    expect(page).to have_current_path(user_diary_path(diary_owner, diary))
    expect(page).to have_css("h1.diary-date", text: "2026年1月1日")
  end
end
