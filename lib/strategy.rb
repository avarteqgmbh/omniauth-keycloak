require 'omniauth-oauth2'
require 'jwt'
require 'uri'

class OmniAuth::Strategies::Keycloak < OmniAuth::Strategies::OAuth2
  class InvalidToken < Exception; end

  option :client_options, {
    site: 'http://localhost:8080/realms/master',
    authorize_url: 'http://localhost:8080/realms/master/protocol/openid-connect/auth',
    token_url: 'http://localhost:8080/realms/master/protocol/openid-connect/token'
  }

  option :public_key
  option :pkce, true

  uid do
    raw_info['sub']
  end

  extra do
    {
      'raw_info' => raw_info,
      'id_token' => access_token.params['id_token']
    }
  end

  info do
    hash = {
      'name' => raw_info['name'],
      'preffered_username' => raw_info['preferred_username'],
      'given_name' => raw_info['given_name'],
      'family_name' => raw_info['family_name'],
      'email' => raw_info['email'],
      'exp' => raw_info['exp'],
      'iat' => raw_info['iat'],
      'sub' => raw_info['sub'],
      'session_state' => raw_info['session_state'],
      'client_session' => raw_info['client_session'],
      'nonce' => raw_info['nonce'],
      'original_nonce' => session[:nonce]
    }
    hash['realm_access']    = raw_info['realm_access']['roles'] if raw_info['realm_access']
    hash['allowed-origins'] = raw_info['allowed-origins'] if raw_info['allowed-origins']
    hash['resource_access'] = raw_info['resource_access'] if raw_info['resource_access']

    hash
  end

  def request_phase
    session[:nonce] = SecureRandom.hex(24)
    options.authorize_params[:nonce] = session[:nonce]
    super
  end

  # NOTE: the callback url get called twice, in request_phase and callback_phase
  # but: the state and code are only known in callback phase
  # as a consequence, keycloak will deny the requests with "invalid redirect_uri"
  # we remove the code and state here.
  # the state will generated after the first call of callback_url, so we can't access it here
  def callback_url
    url = URI(super)
    if url.query
      query = Hash[URI.decode_www_form(url.query)]
      query.delete('code')
      query.delete('state')

      url.query = (URI.encode_www_form(query) if query.keys.count > 0)
    end
    url.to_s
  end

  def raw_info
    decoded_jwt.first
  end

  def public_key_for_jwt
    OpenSSL::PKey::RSA.new(Base64.decode64(options[:public_key]))
  end

  def decoded_jwt
    JWT.decode(
      access_token.token,
      public_key_for_jwt,
      true,
      {
        algorithm: 'RS256'
      }
    )
  end

  def verify!(expected = {})
    raise InvalidToken, 'Invalid ID Token' unless
      raw_info['exp'].to_i > Time.now.to_i &&
      raw_info['iss'] == expected[:issuer] &&
      Array(raw_info['aud']).include?(expected[:client_id]) && # aud(ience) can be a string or an array of strings
      raw_info['nonce'] == expected[:nonce]
  end

  OmniAuth.config.add_camelization('keycloak', 'Keycloak')
end
