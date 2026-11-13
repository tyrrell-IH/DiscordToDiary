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

        assert_select ".diary-visibility", count: 3
        assert_select ".diary-visibility", text: "非公開", count: 1
        assert_select ".diary-visibility", text: "ユーザー限定公開", count: 1
        assert_select ".diary-visibility", text: "公開", count: 1
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

        assert_select ".diary-visibility", count: 0
      end
    end

    context "when the viewer is not logged in" do
      it "shows only public diaries" do
        get user_diaries_path(diary_owner)
        expect(response.body).to include("2026年1月1日")
        expect(response.body).not_to include("2026年1月2日")
        expect(response.body).not_to include("2026年1月3日")

        assert_select ".diary-visibility", count: 0
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

  describe "GET /users/:user_id/diaries/:id" do
    it "returns 200 ok response" do
      get user_diary_path(diary_owner, public_diary)
      expect(response).to have_http_status(:ok)
      assert_select "h1.diary-date", text: "2026年1月1日(木)"
    end

    context "when the viewer is the owner" do
      it "returns 200 for a public diary" do
        log_in_as(diary_owner)
        get user_diary_path(diary_owner, public_diary)

        expect(response).to have_http_status(:ok)
      end

      it "returns 200 for a members-only diary" do
        log_in_as(diary_owner)
        get user_diary_path(diary_owner, members_only_diary)

        expect(response).to have_http_status(:ok)
      end

      it "returns 200 for a private diary" do
        log_in_as(diary_owner)
        get user_diary_path(diary_owner, private_diary)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the viewer is logged in as another user" do
      let(:viewer) { FactoryBot.create(:user) }

      it "returns 200 for a public diary" do
        log_in_as(viewer)
        get user_diary_path(diary_owner, public_diary)

        expect(response).to have_http_status(:ok)
      end

      it "returns 200 for a members-only diary" do
        log_in_as(viewer)
        get user_diary_path(diary_owner, members_only_diary)

        expect(response).to have_http_status(:ok)
      end

      it "returns 404 for a private diary" do
        log_in_as(viewer)
        get user_diary_path(diary_owner, private_diary)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the viewer is not logged in" do
      it "returns 200 for a public diary" do
        get user_diary_path(diary_owner, public_diary)

        expect(response).to have_http_status(:ok)
      end

      it "returns 404 for a members-only diary" do
        get user_diary_path(diary_owner, members_only_diary)

        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for a private diary" do
        get user_diary_path(diary_owner, private_diary)

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "original post links" do
      let(:server_id) { "11111" }
      let(:channel_id) { "22222" }

      let!(:entry) do
        FactoryBot.create(:diary_entry,
                          diary: public_diary,
                          discord_message_id: "33333")
      end

      before do
        allow(Rails.application.credentials)
          .to receive(:fetch).with(:discord)
                             .and_return({
                                           server_id: server_id,
                                           channel_id: channel_id
                                         })
      end

      context "when the viewer is logged in" do
        it "shows the original post link with the correct URL" do
          log_in_as(diary_owner)
          get user_diary_path(diary_owner, public_diary)

          expected_url =
            "https://discord.com/channels/#{server_id}/#{channel_id}/#{entry.discord_message_id}"

          assert_select "a[href=?]", expected_url, text: "元の投稿"
        end
      end

      context "when the viewer is not logged in" do
        it "does not show the original post link" do
          get user_diary_path(diary_owner, public_diary)

          expect(response).to have_http_status(:ok)
          assert_select ".original-link a", count: 0
        end
      end
    end
  end
end
