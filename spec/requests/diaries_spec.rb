require 'rails_helper'

RSpec.describe "Diaries", type: :request do
  let(:diary_owner) { FactoryBot.create(:user) }
  let!(:public_diary) { FactoryBot.create(:diary,
                                          user: diary_owner,
                                          visibility: "everyone",
                                          date: Date.new(2026, 1, 1)) }
  let!(:private_diary) { FactoryBot.create(:diary,
                                           user: diary_owner,
                                           visibility: "only_me",
                                           date: Date.new(2026, 1, 3)) }
  let!(:members_only_diary) { FactoryBot.create(:diary,
                                                user: diary_owner,
                                                visibility: "members_only",
                                                date: Date.new(2026, 1, 2)) }
  let!(:oldest_diary) { FactoryBot.create(:diary,
                                          user: diary_owner,
                                          visibility: "everyone",
                                          date: Date.new(2025, 12, 1)) }

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
      let(:another_diary_owner) { FactoryBot.create(:user) }
      let!(:another_owner_diary) do
        FactoryBot.create(:diary,
                          user: another_diary_owner,
                          visibility: "everyone",
                          date: Date.new(2026, 1, 4))
      end

      it "shows all diaries" do
        log_in_as(diary_owner)
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).to include("2026年1月2日")
        expect(response.body).to include("2026年1月3日")
      end

      it "does not show another owner's diary" do
        log_in_as(diary_owner)
        get user_diaries_path(diary_owner)

        expect(response.body).not_to include("2026年1月4日")
      end

      it "shows diaries in ascending date order" do
        log_in_as(diary_owner)
        get user_diaries_path(diary_owner)

        dates = [ "2026年1月1日", "2026年1月2日", "2026年1月3日" ]

        dates.each do |date|
          expect(response.body).to include(date)
        end

        positions = dates.map { |date| response.body.index(date) }

        expect(positions).to eq(positions.sort)
      end
    end

    context "when the viewer is logged in as another user" do
      let(:viewer) { FactoryBot.create(:user) }

      it "shows public and members-only diaries" do
        log_in_as(viewer)
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).to include("2026年1月2日")
        expect(response.body).not_to include("2026年1月3日")
      end
    end

    context "when the viewer is not logged in" do
      it "shows only public diaries" do
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).not_to include("2026年1月2日")
        expect(response.body).not_to include("2026年1月3日")
      end
    end

    context "when no month is specified" do
      it "shows diaries from the latest month" do
        get user_diaries_path(diary_owner)

        expect(response.body).to include("2026年1月分の日記")
        expect(response.body).to include("2026年1月1日")
        expect(response.body).not_to include("2025年12月1日")
      end
    end

    context "when a valid month is specified" do
      it "shows only diaries from the specified month" do
        get user_diaries_path(diary_owner),
            params: { diary_month: "2025-12" }

        expect(response.body).to include("2025年12月分の日記")
        expect(response.body).to include("2025年12月1日")
        expect(response.body).not_to include("2026年1月1日")
      end
    end

    context "when an invalid month is specified" do
      it "returns a bad request response" do
        get user_diaries_path(diary_owner),
            params: { diary_month: "2026-13" }

        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when there are no diaries at all" do
      it "shows the message 「日記がありません。」" do
        no_diary_user = FactoryBot.create(:user)
        get user_diaries_path(no_diary_user)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("日記がありません")
      end
    end

    context "when there are no diaries in the specified month" do
      it "shows the message 「日記がありません。」" do
        get user_diaries_path(diary_owner),
            params: { diary_month: "2026-12" }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("2026年12月分の日記")
        expect(response.body).to include("日記がありません")
      end
    end
  end
end
