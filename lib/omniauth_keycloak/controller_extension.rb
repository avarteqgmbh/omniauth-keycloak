require 'active_support/concern'

module OmniauthKeycloak::ControllerExtension
  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_filter)
      before_filter :authenticate, :except => [:callback,:omniauth_error_callback,:revoke,:logout_user_callback]
    else
      before_action :authenticate, :except => [:callback,:omniauth_error_callback,:revoke,:logout_user_callback]
    end

    include OmniauthKeycloak::ControllerHelperMethods

  end
end
