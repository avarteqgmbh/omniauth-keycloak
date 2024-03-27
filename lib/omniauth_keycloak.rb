require 'omniauth_keycloak/engine' if defined? Rails

module OmniauthKeycloak
  autoload :Configuration,               File.expand_path('omniauth_keycloak/configuration', __dir__)
  autoload :Cmd,                         File.expand_path('omniauth_keycloak/cmd', __dir__)
  autoload :KeycloakToken,               File.expand_path('omniauth_keycloak/keycloak_token', __dir__)
  autoload :ControllerExtension,         File.expand_path('omniauth_keycloak/controller_extension', __dir__)
  autoload :OmniauthControllerExtension, File.expand_path('omniauth_keycloak/omniauth_controller_extension', __dir__)
  autoload :ApiControllerExtension,      File.expand_path('omniauth_keycloak/api_controller_extension', __dir__)
  autoload :Engine,                      File.expand_path('omniauth_keycloak/engine', __dir__)
  autoload :SharedControllerMethods,     File.expand_path('omniauth_keycloak/shared_controller_methods', __dir__)
  autoload :ControllerHelperMethods,     File.expand_path('omniauth_keycloak/controller_helper_methods', __dir__)
  autoload :Rack,                        File.expand_path('omniauth_keycloak/rack', __dir__)

  autoload :ApplicationController,
           File.expand_path('../app/controllers/omniauth_keycloak/application_controller', __dir__)
  autoload :CallbackController,
           File.expand_path('../app/controllers/omniauth_keycloak/callback_controller', __dir__)
  autoload :SessionsController,
           File.expand_path('../app/controllers/omniauth_keycloak/sessions_controller', __dir__)

  class << self
    def init(oidc_json = nil, config_prefix = '')
      @config = ::OmniauthKeycloak::Configuration.new(oidc_json, config_prefix)
      yield(@config) if block_given?

      self
    end # #init

    def config
      @config ||= ::OmniauthKeycloak::Configuration.new
    end # .config

    def log(msg)
      if defined? Rails
        Rails.logger.debug("[OmniauthKeycloak] #{msg}")
      else
        puts "[OmniauthKeycloak] #{msg}"
      end
    end # #log

    def cmd
      OmniauthKeycloak::Cmd
    end # #cmd

    def register_rack(instance)
      log('register Rack Middleware')
      instance.use OmniAuth::Builder do
        provider(
          :keycloak, OmniauthKeycloak.config.client_id, OmniauthKeycloak.config.client_secret,
          scopes: OmniauthKeycloak.config.scope,
          public_key: OmniauthKeycloak.config.public_key,
          client_options: {
            site: OmniauthKeycloak.config.url,
            authorize_url: OmniauthKeycloak.config.authorize_url,
            token_url: OmniauthKeycloak.config.token_endpoint
          }
        )

        OmniAuth.config.on_failure = proc do |env|
          OmniauthKeycloak::CallbackController.action(:omniauth_error_callback).call(env)
          # this will invoke the omniauth_error_callback action in ApplicationController.
        end
      end
    end # #register_rack
  end # class << self
end

require File.expand_path('strategy', __dir__)
