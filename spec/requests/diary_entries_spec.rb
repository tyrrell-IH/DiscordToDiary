require 'rails_helper'

RSpec.describe "DiaryEntries", type: :request do
  let!(:entry) { FactoryBot.create(:diary_entry) }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:discord] = nil
  end

  describe "GET /diary_entries/:id/edit" do
    it "returns 200 ok response" do
      get edit_diary_entry_path(entry)

      expect(response).to have_http_status(:ok)
      assert_select "h1.diary-entry-edit-title", text: "投稿を編集"
    end
  end
end
