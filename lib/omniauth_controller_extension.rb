require 'active_support/concern'

module OmniauthKeycloak
  module OmniauthControllerExtension
    extend ActiveSupport::Concern
    include OmniauthKeycloak::ControllerExtension

    included do
      protected

      def login(keycloak_token,refresh_token = nil)
        keycloak_token.refresh_token = refresh_token if refresh_token
        Rails.cache.write(keycloak_token.sub,keycloak_token,:expires_in => OmniauthKeycloak.config.token_cache_expires_in)
        session[:omniauth_keycloak_sub] = keycloak_token.sub
      end

      def logout
        clear_session
        render text: "Logout successfull"
      end

      def logout_keycloak
        clear_session

        url = ENV['keycloak_url'] +  "/protocol/openid-connect/logout"
        if OmniauthKeycloak.config.logout_redirect_url
          url += "?post_logout_redirect_uri=#{OmniauthKeycloak.config.logout_redirect_url}"
        else
          url += "?post_logout_redirect_uri=#{request.base_url}"
        end
        redirect_to url
      end

      def check_client_roles(token)
        (token.client_roles & OmniauthKeycloak.config.allowed_client_roles).count > 0
      end

      def check_realm_roles(token)
        (token.realm_roles & OmniauthKeycloak.config.allowed_realm_roles).count > 0
      end

    end
  end
end
