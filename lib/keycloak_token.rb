#This class parses an keycloak access token and extracts the information.
#To do this a public key from keycloak is needed
#After extracting you can access the informations or the user roles and use the
#verify method to verify if an token is valid.
module OmniauthKeycloak
  class KeycloakToken
    class InvalidToken < Exception; end
    KEYS = [:jti, :exp, :iat, :iss, :aud, :sub, :nbf, :azp, :nonce, :allowed_origins, :resource_access, :realm_access]

    attr_reader :token, :decoded_token, :public_key, :client_name
    attr_accessor :jti, :exp, :iat, :iss, :aud, :sub
    attr_accessor :nbf, :azp, :nonce, :allowed_origins, :resource_access, :realm_access
    attr_accessor :attributes

    def initialize(token,public_key,client_name)
        @token = token
        @public_key = public_key
        @client_name = client_name
        @decoded_token = decode_token[0]  #array[0] = attributes, array[1] = algorithm
        KEYS.each do |key|
            self.send "#{key}=", @decoded_token[key.to_s]
        end
        #instance_variable_set("@#{key}", @decoded_token[key.to_s])
        set_attributes
    end

    #extract all user attributes
    def set_attributes
      @attributes ||= {}
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
      JWT.decode @token, OpenSSL::PKey::RSA.new(@public_key), true, { :algorithm => 'RS256' }
    end

    #verify if token is valid
    def verify!(expected = {})
      @decoded_token['exp'].to_i > Time.now.to_i &&
      @decoded_token['iss'] == expected[:issuer] &&
      Array(@decoded_token['aud']).include?(expected[:client_id]) && # aud(ience) can be a string or an array of strings
      @decoded_token['nonce'] == expected[:nonce] or
      raise InvalidToken.new('Invalid ID Token')
    end
  end
end
