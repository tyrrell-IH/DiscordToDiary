require 'rails_helper'

RSpec.describe "Login and logout", type: :system do
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

  it "logs the user in and logs them out" do
    visit login_path
    click_button "ログインする"

    user = User.find_by!(discord_user_id: auth_info.uid)

    expect(page).to have_current_path(user_diaries_path(user))
    expect(page).to have_content(auth_info.info.name)

    click_button "ログアウト"

    expect(page).to have_current_path(login_path)
    expect(page).to have_content("ログインする")
  end
end
