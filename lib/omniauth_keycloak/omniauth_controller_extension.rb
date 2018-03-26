require 'active_support/concern'

module OmniauthKeycloak::OmniauthControllerExtension
  extend ActiveSupport::Concern
  include OmniauthKeycloak::ControllerExtension

  included do
    protected
    unless respond_to?(:env)
      def env
        request.env
      end
    end

    def login(keycloak_token,refresh_token = nil)
      keycloak_token.refresh_token = refresh_token if refresh_token
      Rails.cache.write(keycloak_token.sub,keycloak_token,:expires_in => OmniauthKeycloak.config.token_cache_expires_in.minutes)
      session[:omniauth_keycloak_sub] = keycloak_token.sub
    end

    def logout
      clear_session
      render text: "Logout successfull"
    end

    def logout_keycloak
      clear_session

      url = OmniauthKeycloak.config.url +  "/protocol/openid-connect/logout"
      if OmniauthKeycloak.config.logout_redirect_url
        url += "?post_logout_redirect_uri=#{OmniauthKeycloak.config.logout_redirect_url}"
      else
        url += "?post_logout_redirect_uri=#{request.base_url}"
      end
      redirect_to url
    end

    def check_client_roles(token)
      OmniauthKeycloak.log("User client_roles: #{token.client_roles}")
      (token.client_roles & OmniauthKeycloak.config.allowed_client_roles).count > 0
    end

    def check_realm_roles(token)
      OmniauthKeycloak.log("User realm_roles: #{token.realm_roles}")
      (token.realm_roles & OmniauthKeycloak.config.allowed_realm_roles).count > 0
    end

  end
end
