class OmniauthKeycloak::Engine < ::Rails::Engine
  isolate_namespace OmniauthKeycloak


  initializer "omniauth-keycloak.middleware" do |app|

#    app.config.middleware.delete OmniAuth::Builder
    app.config.middleware.use OmniAuth::Builder do

      provider(:keycloak, OmniauthKeycloak.config.client_id, OmniauthKeycloak.config.client_secret, {
        scope:      "openid",
        public_key: OmniauthKeycloak.config.public_key, 
        client_options: {
          site:          OmniauthKeycloak.config.url,
          authorize_url: OmniauthKeycloak.config.authorize_url,
          token_url:     OmniauthKeycloak.config.token_endpoint
        }
      })

      OmniAuth.config.on_failure = Proc.new do |env|
        OmniauthKeycloak::CallbackController.action(:omniauth_error_callback).call(env)
        #this will invoke the omniauth_error_callback action in ApplicationController.
      end
    end
  end
end