require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns a 200 ok response" do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /auth/failure" do
    it "redirects to /login" do
      get auth_failure_path
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Discordログインを完了できませんでした")
    end
  end

  context "with mocked Discord authentication" do
    let(:auth_info) do
      OmniAuth::AuthHash.new(
        provider: "discord",
        uid: "12345",
        info: {
          name: "test",
          image: "https://example.com/image.png"
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

    describe "GET /auth/discord/callback" do
      it "creates a user and logs them in" do
        expect {
          get  auth_discord_callback_path
        }.to change(User, :count).by(1)

        user = User.find_by!(discord_user_id: auth_info.uid)

        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(user_diaries_path(user))
        expect(flash[:notice]).to eq("ログインしました")
      end
    end

    describe "DELETE /logout" do
      it "logs them out and redirects to /login" do
        get auth_discord_callback_path
        user = User.find_by!(discord_user_id: auth_info.uid)
        expect(session[:user_id]).to eq(user.id)

        delete logout_path
        expect(session[:user_id]).to be_nil
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("ログアウトしました")
      end
    end
  end
end
