class OmniauthKeycloak::Config
    attr_accessor :allowed_realm_roles, :allowed_client_roles, :token_cache_expires_in
    def initialize
      @allowed_realm_roles = ["admin"]
      @allowed_client_roles = ["admin"]
      @token_cache_expires_in = 10.minutes
    end
end
