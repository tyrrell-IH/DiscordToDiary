require 'rails_helper'

RSpec.describe "Return to diary list", type: :system do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary) { FactoryBot.create(:diary,
                                   user: diary_owner,
                                   visibility: "everyone",
                                   date: Date.new(2026, 1, 1)) }

  it "returns to the diary list for the same month" do
    visit user_diary_path(diary_owner, diary)

    list_path = user_diaries_path(
      diary_owner,
      diary_month: diary.date.strftime("%Y-%m")
    )

    expect(page).to have_link("日記一覧に戻る", href: list_path, count: 2)

    first(".diary-back-link", text: "日記一覧に戻る").click

    expect(page).to have_current_path(list_path)
    expect(page).to have_css("h1.diary-month", text: "2026年1月分の日記")
  end
end
