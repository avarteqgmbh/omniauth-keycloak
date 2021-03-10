class OmniauthKeycloak::Configuration
  attr_accessor :allowed_realm_roles, :allowed_client_roles, :token_cache_expires_in, :login_redirect_url,
                :logout_redirect_url, :allowed_realm_roles_api, :allowed_client_roles_api, :client_only
  attr_writer   :scope

  def initialize(oidc_json = nil)
    @allowed_realm_roles = []
    @allowed_client_roles = []
    @allowed_realm_roles_api = []
    @allowed_client_roles_api = []
    @scope = nil
    @token_cache_expires_in = begin
      10.minutes
    rescue StandardError
      10 * 60
    end

    @_oidc = if oidc_json
               JSON.parse(oidc_json)
             else
               {}
             end
  end

  def load_routes
    require File.expand_path('../../config/routes', __dir__)
  end

  def root
    File.expand_path('../..', __dir__)
  end

  def public_key
    ENV['keycloak_public_key']
  end

  def client_id
    ENV['keycloak_client_id']     || @_oidc['resource']
  end

  def client_secret
    ENV['keycloak_client_secret'] || @_oidc['credentials'].try(:[], 'secret')
  end

  def url
    ENV['keycloak_url'] || @_oidc['auth-server-url']
  end

  def authorize_url
    ENV['keycloak_authorize_url'] || "#{realm_url}/protocol/openid-connect/auth"
  end

  def realm
    ENV['keycloak_realm']         || @_oidc['realm']
  end

  def scope
    ENV['keycloak_scope'] || @scope
  end

  def realm_url
    "#{url}/realms/#{realm}"
  end

  def token_endpoint
    ENV['keycloak_token_endpoint'] || "#{realm_url}/protocol/openid-connect/token"
  end

  def disable_rack=(value)
    self.client_only = value
  end

  ##
  # parameter:
  # * segments      admin funcitonality which will used, e.g. users
  def admin_api(segment)
    URI.join(url, 'auth/admin/realms/', "#{realm}/", segment).to_s
  end
end
