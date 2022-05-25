class OmniauthKeycloak::Configuration
  attr_accessor :allowed_realm_roles, :allowed_client_roles, :token_cache_expires_in, :login_redirect_url, :logout_redirect_url, :allowed_realm_roles_api, :allowed_client_roles_api, :client_only
  attr_writer   :scope

  def initialize(oidc_json = nil)
    @allowed_realm_roles = []
    @allowed_client_roles = []
    @allowed_realm_roles_api = []
    @allowed_client_roles_api = []
    @scope = nil
    @token_cache_expires_in = 10.minutes


    @_oidc = if oidc_json
               JSON.parse(oidc_json)
             else 
               {}
             end

    detect_server_prefix
  end

  def load_routes
    require File.expand_path('../../../config/routes', __FILE__)
  end # #load_routes

  def root
    return File.expand_path('../../../', __FILE__)
  end # #root

  def public_key
    ENV['keycloak_public_key']
  end # #public_key

  def client_id
    ENV['keycloak_client_id']     || @_oidc['resource']
  end # #client_id

  def client_secret
    ENV['keycloak_client_secret'] || @_oidc['credentials'].try(:[], 'secret')
  end # #client_secret

  def url
    ENV['keycloak_url'] || @_oidc['auth-server-url']
  end # #url

  def discovery_url
    ENV['keycloak_discovery_url'] || "#{self.realm_url}/.well-known/openid-configuration"
  end # #discovery_url

  def discovery_object
    unless Rails.env.test?
      HTTParty.get(discovery_url) || {}
    end
  end

  def authorize_url
    ENV['keycloak_authorize_url'] || discovery_object()["authorization_endpoint"] || "#{self.realm_url}/protocol/openid-connect/auth"
  end # #authorize_url

  def realm
    ENV['keycloak_realm']         || @_oidc['realm']
  end # #realm

  def scope
    ENV['keycloak_scope'] || @scope
  end # #scope

  def server_prefix
    @_server_prefix ||= '/auth/'
  end

  def realm_url
    URI::join(self.url, self.server_prefix, 'realms/', "#{self.realm}").to_s
  end # #realm_url

  def token_endpoint
    ENV['keycloak_token_endpoint'] || discovery_object()["token_endpoint"] || "#{self.realm_url}/protocol/openid-connect/token"
  end # #token_endpoint

  def disable_rack=(value)
    self.client_only = value
  end # #disable_rack=

  ##
  # parameter:
  # * segments      admin funcitonality which will used, e.g. users
  def admin_api(segment)
    URI::join(self.url, self.server_prefix, 'admin/realms/', "#{self.realm}/", segment).to_s
  end # #admin_api

  def detect_server_prefix
  end
end
