class OmniauthKeycloak::SessionsController < ApplicationController
  include OmniauthKeycloak::OmniauthControllerExtension

  layout false
  skip_before_filter :authenticate, :only => [:login_user, :logout_user, :logout_session]

  def login_user
    authenticate
  end

  def logout_user
    logout_keycloak
  end

  #def logout_session
  #    logout_keycloak
  #end

end
