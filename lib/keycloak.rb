require 'omniauth-oauth2'
require 'jwt'

module OmniAuth
  module Strategies
    class Keycloak < OmniAuth::Strategies::OAuth2
      class InvalidToken < Exception; end
      attr_accessor :decoded_token


      option :client_options, {
        :site => 'http://localhost:8080/auth/realms/master',
        :authorize_url => 'http://localhost:8080/auth/realms/master/protocol/openid-connect/auth',
        :token_url => 'http://localhost:8080/auth/realms/master/protocol/openid-connect/token'
      }

      option :public_key

      def request_phase
        session[:nonce] = SecureRandom.hex(24)
        options.authorize_params[:nonce] = session[:nonce]
        super
      end


      def callback_phase
        super
      end

      uid do
        @decoded_token = decode_token[0]
        @decoded_token['sub']
      end

      credentials do
        {"id_token" => access_token.params['id_token'],
        "decoded_access_token" => @decoded_token }
      end

      info do

        hash = {
          "name" => @decoded_token['name'],
          "preffered_username" => @decoded_token['preferred_username'],
          "given_name" => @decoded_token['given_name'],
          "family_name" => @decoded_token['family_name'],
          "email" => @decoded_token['email'],
          "exp" => @decoded_token['exp'],
          "iat"=> @decoded_token['iat'],
          "sub" => @decoded_token['sub'],
          "session_state" => @decoded_token['session_state'],
          "client_session" => @decoded_token['client_session'],
          "nonce" => @decoded_token['nonce'],
        }
        if @decoded_token['realm_access']
          hash['realm_access'] = @decoded_token['realm_access']['roles']
        end
        if @decoded_token['allowed-origins']
          hash["allowed-origins"] = @decoded_token['allowed-origins']
        end
        if @decoded_token['resource_access']
          hash["resource_access"] = @decoded_token['resource_access']
        end

        hash
      end

      def get_token
        access_token.token
      end

      def decode_token
        JWT.decode get_token, OpenSSL::PKey::RSA.new(options[:public_key]), true, { :algorithm => 'RS256' }
      end

      def verify!(expected = {})
        @decoded_token['exp'].to_i > Time.now.to_i &&
        @decoded_token['iss'] == expected[:issuer] &&
        Array(@decoded_token['aud']).include?(expected[:client_id]) && # aud(ience) can be a string or an array of strings
        @decoded_token['nonce'] == expected[:nonce] or
        raise InvalidToken.new('Invalid ID Token')
      end

    end
  end
end
