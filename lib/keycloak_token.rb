#This class parses an keycloak access token and extracts the information.
#To do this a public key from keycloak is needed
#After extracting you can access the informations or the user roles and use the
#verify method to verify if an token is valid.
module OmniauthKeycloak
  class KeycloakToken
    class InvalidToken < Exception; end
    KEYS = [:jti, :exp, :iat, :iss, :aud, :sub, :nbf, :azp, :nonce, :allowed_origins, :resource_access, :realm_access]

    attr_reader :token, :decoded_token, :public_key, :client_name, :client_secret
    attr_accessor :jti, :exp, :iat, :iss, :aud, :sub, :refresh_token
    attr_accessor :nbf, :azp, :nonce, :allowed_origins, :resource_access, :realm_access
    attr_accessor :attributes

    def initialize(token,public_key,client_name,client_secret)
        @token = token
        @public_key = public_key
        @client_name = client_name
        @client_secret = client_secret
        @decoded_token = decode_token[0]  #array[0] = attributes, array[1] = algorithm
        KEYS.each do |key|
            self.send "#{key}=", @decoded_token[key.to_s]
        end
        #instance_variable_set("@#{key}", @decoded_token[key.to_s])
        set_attributes
    end

    #extract all user attributes
    def set_attributes
      @attributes = {}
      attr = @decoded_token.keys - KEYS.map {|k| k.to_s}
      attr.each do |attribute|
        @attributes[attribute] = @decoded_token[attribute]
      end
    end

    #get all roles  for current user, realm and client roles
    def roles
      client_roles(@client_name) + realm_roles
    end

    #return hash with clientname => roles
    def roles_hash
      hash = {}
      if resource_access
          resource_access.each do |client|
            hash[client[0]] = client[1]['roles']
        end
      end
      hash
    end

    def role?(client_name,role_name,use_realm_roles = false)
        roles = client_roles(client_name)
        if use_realm_roles
          roles = roles + realm_roles
        end

        roles.include?(role_name)
    end

    def client_roles(client_name)
      r = roles_hash[client_name]
      r ||= []
    end

    def realm_roles
      if realm_access
        realm_access['roles']
      else
        []
      end
    end

    def decode_token
      JWT.decode @token, OpenSSL::PKey::RSA.new(Base64.decode64(@public_key)), true, { :algorithm => 'RS256' }
    end

    def expired?
        exp.to_i < Time.now.to_i
    end

    #returns new KeycloakToken if refresh token is available
    #@token_endpoint token endpoint keycloak
    #@options :refresh_token refreshtoken or @refresh_token
    #
    def refresh(token_endpoint,options = {})
      if options[:refresh_token]
          refresh_token = options.delete(:refresh_token)
      else
          refresh_token = @refresh_token
      end
      options[:token_url] = token_endpoint
      new_token = oauth2token({refresh_token: refresh_token,expires_at: @exp},options).refresh!

      keycloak_token = OmniauthKeycloak::KeycloakToken.new(new_token.token,@public_key,@client_name,@client_secret)
      if new_token.refresh_token
        keycloak_token.refresh_token = new_token.refresh_token
      end
      keycloak_token
    end

    def oauth2client(options = {})
      OAuth2::Client.new(@client_id,@client_secret,options)
    end

    def oauth2token(token_options = {},client_options = {})
      OAuth2::AccessToken.new(oauth2client(client_options),@token,token_options)
    end

    #verify if token is valid
    def verify!(expected = {})
      byebug
      @decoded_token['exp'].to_i > Time.now.to_i &&
      @decoded_token['iss'] == expected[:issuer] &&
      Array(@decoded_token['aud']).include?(expected[:client_id]) && # aud(ience) can be a string or an array of strings
      @decoded_token['nonce'] == expected[:nonce] or
      raise InvalidToken.new('Invalid ID Token')
    end

    #Get KeycloakToken with client credentials grant type
    def self.client_credentials(client_id,client_secret,token_endpoint,public_key)
      client = OAuth2::Client.new(client_id,client_secret,{token_url: token_endpoint})
      token  = client.client_credentials.get_token
      OmniauthKeycloak::KeycloakToken.new(token.token,public_key,client_id,client_secret)
      #no refesh token for client credetials grant type
    end
  end
end
