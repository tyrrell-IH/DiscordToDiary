discord_credentials =
  if Rails.env.test?
    {
      client_id: "test_client_id", client_secret: "test_client_secret"
    }
  else
    Rails.application.credentials.fetch(:discord)
  end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
           discord_credentials.fetch(:client_id),
           discord_credentials.fetch(:client_secret),
           scope: "identify"
end
