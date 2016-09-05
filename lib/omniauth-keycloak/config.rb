class OmniauthKeycloak::Config
    attr_accessor :allowed_realm_roles, :allowed_client_roles, :token_cache_expires_in, :login_redirect_url, :logout_redirect_url, :allowed_realm_roles_api, :allowed_client_roles_api

    def initialize
      @allowed_realm_roles = []
      @allowed_client_roles = []
      @allowed_realm_roles_api = []
      @allowed_client_roles_api = []
      @token_cache_expires_in = 10.minutes
    end
end
