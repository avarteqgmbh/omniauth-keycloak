require 'active_support/concern'

module OmniauthKeycloak::ControllerExtension
  extend ActiveSupport::Concern

  included do
    include OmniauthKeycloak::ControllerHelperMethods

    authenticate_exceptions = []
    authenticate_exceptions << :logout_user_callback if method_defined?(:logout_user_callback)
    authenticate_exceptions << :revoke if method_defined?(:revoke)
    authenticate_exceptions << :callback if method_defined?(:callback)
    authenticate_exceptions << :omniauth_error_callback if method_defined?(:omniauth_error_callback)

    if respond_to?(:before_filter)
      before_filter :authenticate, except: authenticate_exceptions
    else
      before_action :authenticate, except: authenticate_exceptions
    end
  end
end
