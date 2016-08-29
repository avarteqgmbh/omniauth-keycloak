class SessionsController < ActionController::Base
  include OmniauthKeycloak::OmniauthControllerExtension

  def login_user
    authenticate
  end

  def logout_user
    logout
  end

  def logout_session
      logout_keycloak
  end

end
