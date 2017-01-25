require 'active_support/concern'

module OmniauthKeycloak::ApiControllerExtension
  extend ActiveSupport::Concern

  included do
    rescue_from JWT::ExpiredSignature, with: :signature_expired
    rescue_from JWT::VerificationError, with: :invalid_signature
    rescue_from JWT::DecodeError, with: :decode_error

    def signature_expired
      OmniauthKeycloak.log('Signature expired')
      render json: 'Signature expired', status: 400
    end

    def invalid_signature
      OmniauthKeycloak.log('Invalid Signature')
      render json: 'Invalid Signature', status: 400
    end

    def decode_error
      OmniauthKeycloak.log('Token decode error')
      render json: 'Token decode error', status: 400
    end

    def authenticate
      token = get_token
      if token
        unless check_client_roles_api(token) or check_realm_roles_api(token)
          OmniauthKeycloak.log("Allowed Roles #{OmniauthKeycloak.config.allowed_realm_roles_api | OmniauthKeycloak.config.allowed_client_roles_api}")
          OmniauthKeycloak.log("Token Roles:\n\t#{token.roles * "\n\t"}")
          OmniauthKeycloak.log('Access denied')
          render json: 'Access denied', status: 403
        end
      else

        render json: 'OAuth2 Token error: Token not found', status: 400
      end
    end

    protected

    def get_token
      token = request.headers['HTTP_AUTHORIZATION']
      if token
        token['Bearer'] = '' if token.include?("Bearer")
        token = token.strip
        token = OmniauthKeycloak::KeycloakToken.new(token)
        OmniauthKeycloak.log("Request from: #{token.sub}")
        token
      else
        nil
      end
    end
  end

  def check_client_roles_api(token)
    (token.client_roles & OmniauthKeycloak.config.allowed_client_roles_api).count > 0
  end

  def check_realm_roles_api(token)
    (token.realm_roles & OmniauthKeycloak.config.allowed_realm_roles_api).count > 0
  end

end
