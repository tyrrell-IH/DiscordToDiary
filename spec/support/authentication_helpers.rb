module AuthenticationHelpers
  def log_in_as(user)
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new(
      provider: "discord",
      uid: user.discord_user_id,
      info: {
        name: user.discord_user_name,
        image: user.avatar_url
      },
      extra: {
        raw_info: {
          global_name: user.discord_global_name
        }
      }
    )

    get "/auth/discord/callback"
  end
end
