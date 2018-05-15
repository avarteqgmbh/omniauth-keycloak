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
  end # class << self
end


require File.expand_path('../strategy', __FILE__)
