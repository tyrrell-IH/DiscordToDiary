require 'rails_helper'

RSpec.describe "Diaries", type: :request do
  let(:diary_owner) { FactoryBot.create(:user) }
  let!(:public_diary) { FactoryBot.create(:diary,
                                          user: diary_owner,
                                          visibility: "everyone",
                                          date: Date.new(2026, 1, 1)) }
  let!(:members_only_diary) { FactoryBot.create(:diary,
                                                user: diary_owner,
                                                visibility: "members_only",
                                                date: Date.new(2026, 2, 2)) }
  let!(:private_diary) { FactoryBot.create(:diary,
                                           user: diary_owner,
                                           visibility: "only_me",
                                           date: Date.new(2026, 3, 3)) }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:discord] = nil
  end

  describe "GET /users/:user_id/diaries" do
    it "returns 200 ok response" do
      get user_diaries_path(diary_owner)
      expect(response).to have_http_status(:ok)
    end

    context "when the viewer is the owner" do
      it "shows all diaries" do
        log_in_as(diary_owner)
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).to include("2026年2月2日")
        expect(response.body).to include("2026年3月3日")
      end
    end

    context "when the viewer is logged in as another user" do
      let(:viewer) { FactoryBot.create(:user) }

      it "shows public and members-only diaries" do
        log_in_as(viewer)
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).to include("2026年2月2日")
        expect(response.body).not_to include("2026年3月3日")
      end
    end

    context "when the viewer is not logged in" do
      it "shows only public diaries" do
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).not_to include("2026年2月2日")
        expect(response.body).not_to include("2026年3月3日")
      end
    end
  end
end
