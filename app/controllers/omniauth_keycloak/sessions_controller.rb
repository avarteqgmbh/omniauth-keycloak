class OmniauthKeycloak::SessionsController < ApplicationController
  include OmniauthKeycloak::OmniauthControllerExtension

  layout false
  if respond_to?(:skip_before_filter)
    skip_before_filter :authenticate, :only => [:login_user, :logout_user, :logout_session]
  else
    skip_before_action :authenticate, :only => [:login_user, :logout_user, :logout_session]
  end

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
