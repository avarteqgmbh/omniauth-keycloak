require 'active_support/concern'

module OmniauthKeycloak::ControllerHelperMethods
  extend ActiveSupport::Concern

  included do

    helper_method :current_omniauth_user

    protected

    def authenticate
      unless current_omniauth_user
        OmniauthKeycloak.log('Current User is blank')
        session[:redirect_after_login] = request.url
        render(
          {
            template:   'layouts/post_redirect',
            layout:     'layouts/blank_oauth',
            locals: { auth_url: '/auth/keycloak'}
          }
        )
        return false
      end
      return true
    end

    def current_omniauth_user
      cached_token
    end # #current_omniauth_user


    def stored_redirect_url
      session[:redirect_after_login]
    end

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
