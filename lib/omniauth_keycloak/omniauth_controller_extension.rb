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

    def login(keycloak_token,refresh_token = nil, token_cache_expires = OmniauthKeycloak.config.token_cache_expires_in.minutes)
      keycloak_token.refresh_token = refresh_token if refresh_token
      OmniauthKeycloak.log('Remember token')
      Rails.cache.write(keycloak_token.sub,keycloak_token,:expires_in => token_cache_expires)
      session[:omniauth_keycloak_sub] = keycloak_token.sub
      
    end

    def logout
      clear_session
      render text: "Logout successfull"
    end

    def logout_keycloak(realm_url = OmniauthKeycloak.config.realm_url, logout_redirect_url = OmniauthKeycloak.config.logout_redirect_url)
      clear_session

      url = realm_url +  "/protocol/openid-connect/logout"
      if logout_redirect_url
        url += "?redirect_uri=#{logout_redirect_url}"
      else
        url += "?redirect_uri=#{request.base_url}"
      end
      redirect_to url
    end

    def check_client_roles(token, allowed_client_roles = OmniauthKeycloak.config.allowed_client_roles)
      OmniauthKeycloak.log("User client_roles: #{token.client_roles}")
      (token.client_roles & allowed_client_roles).count > 0
    end

    def check_realm_roles(token, allowed_realm_roles = OmniauthKeycloak.config.allowed_realm_roles)
      OmniauthKeycloak.log("User realm_roles: #{token.realm_roles}")
      (token.realm_roles & allowed_realm_roles).count > 0
    end

  end
end
