require 'active_support/concern'

module OmniauthKeycloak::ControllerExtension
  extend ActiveSupport::Concern

  included do
    if respodn_to?(:before_filter)
      before_filter :authenticate, :except => [:callback,:omniauth_error_callback,:revoke,:logout_user_callback]
    else
      before_action :authenticate, :except => [:callback,:omniauth_error_callback,:revoke,:logout_user_callback]
    end

    helper_method :current_user

    protected

    def authenticate
      unless current_user
        OmniauthKeycloak.log('Current User is blank')
        redirect_to  '/auth/keycloak'
        return false
      end
      return true
    end

    def current_user
      cached_token
    end # #current_user

    def cached_token
      OmniauthKeycloak.log("Fetch #{session[:omniauth_keycloak_sub]}")
      token = Rails.cache.fetch(session[:omniauth_keycloak_sub])
      if !token
        OmniauthKeycloak.log('No decodable Token')
        return nil 
      end

      if token.expired?
        OmniauthKeycloak.log('Token expired')
        refresh_token(token)
      else
        token
      end
    end

    def refresh_token(token)
      begin
        new_token = token.refresh
        new_token.verify!
        Rails.cache.write(new_token.sub,new_token,:expires_in => OmniauthKeycloak.config.token_cache_expires_in)
        return new_token
      rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
        flash[:error] = "token verification failure"
        render :template => 'layouts/error'
      rescue OAuth2::Error => e
        #Refresh Token expired, neues Access Token bei Keycloak anfordern
        #Aktion des Users muss neu gestartet werden
        clear_session
        return
      rescue JWT::VerificationError => e
        #Signatur des Access Tokens ungültig
        clear_session
        return
      end
      return
    end

    def clear_session
      Rails.cache.delete(session[:omniauth_keycloak_sub]) if session[:omniauth_keycloak_sub]
      session.clear
    end


  end
end
