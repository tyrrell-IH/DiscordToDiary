discord_credentials = Rails.application.credentials.fetch(:discord)

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :discord,
           discord_credentials.fetch(:client_id),
           discord_credentials.fetch(:client_secret),
           scope: "identify"
end
