require 'active_support/concern'

module OmniauthKeycloak
  module ControllerExtension
    extend ActiveSupport::Concern

    included do
      before_filter :authenticate, :except => [:callback,:omniauth_error_callback,:revoke,:logout_user_callback]

      helper_method :current_user

      protected

      def authenticate
        redirect_to "/auth/keycloak" unless current_user
      end

      def current_user
        token = Rails.cache.fetch(session[:omniauth_keycloak_sub])
        if token
          if token.expired?
            begin
              new_token = token.refresh
              new_token.verify!
              Rails.cache.write(new_token.sub,new_token,:expires_in => OmniauthKeycloak.config.token_cache_expires_in)
            rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
              flash[:error] = "token verification failure"
              render :template => 'layouts/error'
            rescue OAuth2::Error => e
              #Refresh Token expired, neues Access Token bei Keycloak anfordern
              #Aktion des Users muss neu gestartet werden
              clear_session
              redirect_to "/auth/keycloak"
            rescue JWT::VerificationError => e
              #Signatur des Access Tokens ungültig
              clear_session
              redirect_to "/auth/keycloak"
            end
          else
            token
          end
        else
          byebug
          nil
        end
      end

      def clear_session
        Rails.cache.delete(session[:omniauth_keycloak_sub]) if session[:omniauth_keycloak_sub]
        session.clear
      end


    end
  end
end
