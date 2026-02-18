require 'active_support/concern'

module OmniauthKeycloak::ControllerExtension
  extend ActiveSupport::Concern

  included do
    include OmniauthKeycloak::ControllerHelperMethods

    authenticate_exceptions = %i[logout_user_callback revoke callback omniauth_error_callback]

    if defined?(Rails) && Rails.application.config.respond_to?(:raise_on_missing_callback_actions) && Rails.application.config.raise_on_missing_callback_actions
      raise OmniauthKeycloak::FaultyConfigException,
            "OmniauthKeycloak requires  raise_on_missing_callback_actions to be false,
            otherwise the omniauth integration will not work.
            Please set it to false in your controller,
            e.g. by adding 'self.raise_on_missing_callback_actions = false'
            to your controller class."

    end

    if respond_to?(:before_filter)
      before_filter :authenticate, except: authenticate_exceptions
    else
      before_action :authenticate, except: authenticate_exceptions
    end
  end
end
