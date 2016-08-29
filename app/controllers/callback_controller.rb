
#require_dependency "application_controller"
#module OmniauthKeycloak
  class KeycloakCallbackController <  ApplicationController
    include OmniauthKeycloak::OmniauthControllerExtension

    def callback
      acess_token 		= env['omniauth.auth']['credentials']['token']
      nonce           = env['omniauth.auth']['info']['original_nonce']
      refresh_token   = env['omniauth.auth']['credentials']['refresh_token']

      begin
        token = OmniauthKeycloak::KeycloakToken.new(acess_token)

        token.verify!(nonce: nonce)

        if check_client_roles(token) or check_realm_roles(token)
             login(token,refresh_token)
             if OmniauthKeycloak.config.login_redirect_url
               redirect_to OmniauthKeycloak.config.login_redirect_url
             else
               redirect_to root_path
             end
        else
             flash.now[:error] = "Access denied"
             render :template => 'layouts/error'
        end

      rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
        flash[:error] = "#{e}"
        render :template => 'layouts/error'
      end

    end

    def omniauth_error_callback
      #jwt signature invalid while omniauth strategy
      #env['omniauth.error'] = exception
      #env['omniauth.error.type'] = message_key.to_sym
      #env['omniauth.error.strategy'] = self
      if env['omniauth.error.type'] == :VerificationError
        flash.now[:error] = "Die Signatur des Tokens ist fehlerhaft."
        render :template => 'layouts/error'
      else
        render text: "#{env['omniauth.error']}\n #{env['omniauth.error.type']} \n #{env['omniauth.error.strategy']}"
      end

      #fehlt: OmniAuth::Strategies::OAuth2::CallbackError csrf_detected

    end

    def revoke
      #keycloak token revoke event,revoke all tokens
      Rails.cache.clear
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end

    def logout_user_callback
      #keycloak logout event, logout all Users
      Rails.cache.clear
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end


  #end
end
