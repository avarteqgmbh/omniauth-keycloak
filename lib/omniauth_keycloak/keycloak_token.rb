# This class parses an keycloak access token and extracts the information.
# To do this a public key from keycloak is needed
# After extracting you can access the informations and the user roles and use the
# verify method to verify if an token is valid.
# This class depends on some environment variables:
# ENV[keycloak_client_id]
# ENV[keycloak_client_secret]
# ENV[keycloak_token_endpoint]
# ENV[keycloak_public_key]
# ENV[keycloak_url] :client_session,

class OmniauthKeycloak::KeycloakToken
  class InvalidToken < RuntimeError
  end
  class InvalidSetup < RuntimeError
  end
  KEYS = %i[jti exp iat iss aud sub nbf typ azp nonce session_state client_session allowed_origins resource_access realm_access auth_time acr].freeze

  attr_reader :token, :decoded_token, :public_key, :client_id, :client_secret, :keycloak_url, :config
  # claims see http://openid.net/specs/openid-connect-core-1_0.html#IDToken and additional specifications
  attr_accessor :jti, :exp, :iat, :iss, :aud, :sub, :nbf, :typ, :azp, :nonce, :session_state, :client_session, :allowed_origins, :resource_access, :realm_access, :auth_time, :acr
  attr_accessor :attributes, :refresh_token

  def initialize(token, config = OmniauthKeycloak.config)
    @config = config

    @token = token
    @public_key    = config.public_key
    @client_id     = config.client_id
    @client_secret = config.client_secret
    @keycloak_url  = config.realm_url
    @decoded_token = decode_token[0] # array[0] = attributes, array[1] = algorithm
    KEYS.each do |key|
      self.send "#{key}=", @decoded_token[key.to_s]
    end
    @allowed_origins = @decoded_token["allowed-origins"]
    # instance_variable_set("@#{key}", @decoded_token[key.to_s])
    set_attributes
  end

  # get all roles  for current user, realm and client roles
  def roles
    client_roles + realm_roles
  end

  # return hash with clientname => roles
  def roles_hash
    hash = {}
    if resource_access
      resource_access.each do |client|
        hash[client[0]] = client[1]["roles"]
      end
    end
    hash
  end

  def role?(role_name, use_realm_roles = false)
    roles = client_roles
    roles += realm_roles if use_realm_roles

    roles.include?(role_name)
  end

  def client_roles
    roles_hash[@client_id] || []
  end

  def realm_roles
    if realm_access
      realm_access["roles"]
    else
      []
    end
  end

  def expired?
    exp.to_i < Time.now.to_i
  end

  def id
    self.sub
  end # #id

  # returns new KeycloakToken if refresh token is available
  # @options :refresh_token refreshtoken or @refresh_token
  #
  def refresh(options = {})
    refresh_token = if options[:refresh_token]
                      options.delete(:refresh_token)
                    else
                      @refresh_token
                    end
    options[:token_url] = config.token_endpoint
    new_token = oauth2token({ refresh_token: refresh_token, expires_at: @exp }, options).refresh!

    keycloak_token = OmniauthKeycloak::KeycloakToken.new(new_token.token, config)
    keycloak_token.refresh_token = new_token.refresh_token if new_token.refresh_token
    keycloak_token
  end

  def oauth2client(options = {})
    OAuth2::Client.new(@client_id, @client_secret, options)
  end

  def oauth2token(token_options = {}, client_options = {})
    OAuth2::AccessToken.new(oauth2client(client_options), @token, token_options)
  end

  # verify if token is valid
  def verify!(expected = {})
    expected[:issuer] ||= @keycloak_url
    expected[:client_id] ||= @client_id
    expected[:nonce] ||= @nonce

    raise InvalidToken, "Token expired. is: #{exp}, expected: <= #{Time.now.to_i}" if exp.to_i <= Time.now.to_i
    raise InvalidToken, "Invalid issuer. is: #{iss}, expected: #{expected[:issuer]}" if iss != expected[:issuer]
    raise InvalidToken, "Invalid audience. is: #{aud}, expected: #{expected[:client_id]}" unless (Array(aud) + Array(azp)).compact.include?(expected[:client_id])
    raise InvalidToken, "Invalid nonce. is: #{nonce}, expected: #{expected[:nonce]}" if nonce != expected[:nonce]

    true
  end

  # Get KeycloakToken with passwort grant type
  def self.password(user, password)
    client = OAuth2::Client.new(config.client_id, config.client_secret, token_url: config.token_endpoint)
    token  = client.password.get_token(user, password)
    OmniauthKeycloak::KeycloakToken.new(token.token, config)
  end # .password

  # Get KeycloakToken with client credentials grant type
  def self.client_credentials
    client = OAuth2::Client.new(config.client_id, config.client_secret, token_url: config.token_endpoint)
    token  = client.client_credentials.get_token
    OmniauthKeycloak::KeycloakToken.new(token.token, config)
    # no refesh token for client credentials grant type
  end

  private

  # extract all user attributes
  def set_attributes
    @attributes = {}
    attr = @decoded_token.keys - KEYS.map(&:to_s) - ["allowed-origins"]
    attr.each do |attribute|
      @attributes[attribute] = @decoded_token[attribute]
    end
  end

  def decode_token
    raise InvalidSetup, "Public Key is missing, please check the setup." if @public_key.blank?
    raise InvalidToken, "no token given" if @token.blank?

    JWT.decode @token, OpenSSL::PKey::RSA.new(Base64.decode64(@public_key)), true, algorithm: "RS256"
  end
end
