class OmniauthKeycloak::CallbackController <  OmniauthKeycloak::ApplicationController
  include OmniauthKeycloak::OmniauthControllerExtension
  layout false

  def callback
    json_web_token 	= env['omniauth.auth']['credentials']['token']
    refresh_token   = env['omniauth.auth']['credentials']['refresh_token']

    begin
      token = OmniauthKeycloak::KeycloakToken.new(json_web_token)

      if check_client_roles(token) or check_realm_roles(token)
        login(token,refresh_token)
        OmniauthKeycloak.log('Redirect after login')
        if OmniauthKeycloak.config.login_redirect_url
          redirect_to OmniauthKeycloak.config.login_redirect_url
        elsif stored_redirect_url.present?
          redirect_to stored_redirect_url
        else
          redirect_to main_app.root_path
        end
      else
        OmniauthKeycloak.log('Access denied')
        flash.now[:error] = "Access denied"
        render :template => 'layouts/error'
      end

    rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
      OmniauthKeycloak.log(e.class)
      OmniauthKeycloak.log(e)
      OmniauthKeycloak.log(e.backtrace*"\n")
      flash[:error] = "#{e}"
      render :template => 'layouts/error'
    end

  end

  def omniauth_error_callback
    if env['omniauth.error.type'] == :VerificationError
      flash.now[:error] = "Die Signatur des Tokens ist fehlerhaft."
      render :template => 'layouts/error'
    elsif env['omniauth.error.type'] == :csrf_detected
      flash.now[:error] = "CSRF detected"
      render :template => 'layouts/error'
    elsif  env['omniauth.error.type'] == :access_denied
        flash.now[:error] = "access denied, user has not granted permission for this app to use his data"
        render :template => 'layouts/error'
      else
        render({
          text: "#{env['omniauth.error']}\n #{env['omniauth.error.type']} \n #{env['omniauth.error.strategy']}",
          plain: "#{env['omniauth.error']}\n #{env['omniauth.error.type']} \n #{env['omniauth.error.strategy']}"
        })
      end
    end

    def revoke
      #keycloak token revoke event,revoke all tokens
      Rails.cache.clear
      render :nothing => true, :status => 200, :content_type => 'text/html', body: nil
    end

    def logout_user_callback
      #keycloak logout event, logout all Users
      Rails.cache.clear
      render :nothing => true, :status => 200, :content_type => 'text/html', body: nil
    end

end
