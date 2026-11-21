require 'rails_helper'

RSpec.describe "DiaryEntries", type: :request do
  let!(:diary_owner) { FactoryBot.create(:user) }
  let!(:diary) { FactoryBot.create(:diary, user: diary_owner) }
  let!(:entry) { FactoryBot.create(:diary_entry,
                                   diary: diary,
                                   content: "テスト") }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:discord] = nil
  end

  describe "GET /diary_entries/:id/edit" do
    context "when the viewer is the owner" do
      it "returns 200" do
        log_in_as(entry.diary.user)
        get edit_diary_entry_path(entry)

        expect(response).to have_http_status(:ok)
        assert_select "h1.diary-entry-edit-title", text: "投稿を編集"
        assert_select 'textarea[name="diary_entry[content]"]',
                      text: entry.content
      end
    end

    context "when the viewer is logged in as another user" do
      let(:viewer) { FactoryBot.create(:user) }

      it "returns 404" do
        log_in_as(viewer)
        get edit_diary_entry_path(entry)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the viewer is not logged in" do
      it "returns 404" do
        get edit_diary_entry_path(entry)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /diary_entries/:id" do
    context "when the viewer is the owner" do
      it "updates the content and redirects to the diary" do
        log_in_as(diary_owner)

        patch diary_entry_path(entry),
              params: {
                diary_entry: { content: "内容を更新しました" }
              }

        expect(entry.reload.content).to eq("内容を更新しました")
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(diary_path(entry.diary))
      end
    end

    context "when the viewer is logged in as another user" do
      let(:viewer) { FactoryBot.create(:user) }
      it "returns 404" do
        log_in_as(viewer)

        patch diary_entry_path(entry),
              params: {
                diary_entry: { content: "内容を更新しました" }
              }

        expect(entry.reload.content).to eq("テスト")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the viewer is not logged in as another user" do
      it "returns 404" do
        patch diary_entry_path(entry),
              params: {
                diary_entry: { content: "内容を更新しました" }
              }

        expect(entry.reload.content).to eq("テスト")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
