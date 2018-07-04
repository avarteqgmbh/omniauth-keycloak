module OmniauthKeycloak

  autoload :Config,                      File.expand_path('../omniauth_keycloak/config', __FILE__)
  autoload :KeycloakToken,               File.expand_path('../omniauth_keycloak/keycloak_token', __FILE__)
  autoload :ControllerExtension,         File.expand_path('../omniauth_keycloak/controller_extension',__FILE__)
  autoload :OmniauthControllerExtension, File.expand_path('../omniauth_keycloak/omniauth_controller_extension',__FILE__)
  autoload :ApiControllerExtension,      File.expand_path('../omniauth_keycloak/api_controller_extension',__FILE__)
  autoload :Engine,                      File.expand_path('../omniauth_keycloak/engine', __FILE__)
  autoload :SharedControllerMethods,     File.expand_path('../omniauth_keycloak/shared_controller_methods', __FILE__)
  autoload :Rack,                        File.expand_path('../omniauth_keycloak/rack', __FILE__)

  autoload :CallbackController,          File.expand_path('../../app/controllers/omniauth_keycloak/callback_controller', __FILE__)
  autoload :SessionsController,          File.expand_path('../../app/controllers/omniauth_keycloak/sessions_controller', __FILE__)

  class << self

    def init(oidc_json = nil)
      @config = ::OmniauthKeycloak::Config.new(oidc_json)
      if block_given?
          yield(@config)
      end
    end # #init

    def config
      @config ||= ::OmniauthKeycloak::Config.new
    end # .config

    def log(msg)
      if defined? Rails
        Rails.logger.debug("[OmniauthKeycloak] #{msg}")
      else
        puts "[OmniauthKeycloak] #{msg}"
      end
    end # #log


    def register_rack(instance)
      instance.use OmniAuth::Builder do

        provider(:keycloak, OmniauthKeycloak.config.client_id, OmniauthKeycloak.config.client_secret, {
          scope:      OmniauthKeycloak.config.scope,
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
    end # #register_rack
  end # class << self
end


require File.expand_path('../strategy', __FILE__)
begin
  require File.expand_path('../../config/routes', __FILE__)
rescue => e
  puts e
  puts e.backtrace * "\n"
end
