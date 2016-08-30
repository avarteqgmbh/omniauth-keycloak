Rails.application.config.middleware.delete OmniAuth::Builder
Rails.application.config.middleware.use OmniAuth::Builder do

provider :keycloak, ENV["keycloak_client_id"], ENV["keycloak_client_secret"], scope: "openid", public_key: ENV["keycloak_public_key"],client_options: {:site => ENV["keycloak_url"], :authorize_url => ENV["keycloak_authorize_url"], :token_url => ENV["keycloak_token_endpoint"]}
OmniAuth.config.on_failure = Proc.new do |env|
  OmniauthKeycloak::CallbackController.action(:omniauth_error_callback).call(env)
  #this will invoke the omniauth_error_callback action in ApplicationController.
end
end
