require 'rails_helper'

RSpec.describe "Diary month selection", type: :system do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary1) { FactoryBot.create(:diary,
                                   user: diary_owner,
                                   visibility: "everyone",
                                   date: Date.new(2026, 1, 1)) }
  let!(:diary2) { FactoryBot.create(:diary,
                                   user: diary_owner,
                                   visibility: "everyone",
                                   date: Date.new(2026, 2, 2)) }

  it "shows the diary for the selected month" do
    visit user_diaries_path(diary_owner)

    expect(page).to have_content("2026年2月分の日記")
    expect(page).to have_content("2026年2月2日")

    select "2026年1月", from: "表示する年月"
    click_button "表示"

    expect(page).to have_content("2026年1月分の日記")
    expect(page).to have_content("2026年1月1日")
    expect(page).not_to have_content("2026年2月2日")
  end
end
