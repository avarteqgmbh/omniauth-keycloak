require 'httparty'

class OmniauthKeycloak::Configuration
  attr_accessor :allowed_realm_roles, :allowed_client_roles, :token_cache_expires_in, :login_redirect_url,
                :logout_redirect_url, :allowed_realm_roles_api, :allowed_client_roles_api, :client_only, :config_prefix
  attr_writer   :scope

  def initialize(oidc_json = nil, config_prefix = '')
    @allowed_realm_roles = []
    @allowed_client_roles = []
    @allowed_realm_roles_api = []
    @allowed_client_roles_api = []
    @scope = nil
    @token_cache_expires_in = 10.minutes

    @config_prefix = config_prefix # Must match additional keys in the file

    @_oidc = if oidc_json
               JSON.parse(oidc_json)
             else
               {}
             end
  end

  def load_routes
    require File.expand_path('../../config/routes', __dir__)
  end # #load_routes

  def root
    File.expand_path('../..', __dir__)
  end # #root

  def public_key
    env_value('keycloak_public_key')
  end # #public_key

  def client_id
    env_value('keycloak_client_id') || @_oidc['resource']
  end # #client_id

  def client_secret
    env_value('keycloak_client_secret') || @_oidc['credentials'].try(:[], 'secret')
  end # #client_secret

  def url
    env_value('keycloak_url') || @_oidc['auth-server-url']
  end # #url

  def discovery_url
    env_value('keycloak_discovery_url') || "#{realm_url}/.well-known/openid-configuration"
  end # #discovery_url

  def discovery_object
    ::HTTParty.get(discovery_url) || {}
  rescue HTTParty::Error, SocketError => e
    Rails.logger.error e
    puts '[OmniauthKeycloak] auth-server-url is not a valid url'
    {}
  end

  def authorize_url
    env_value('keycloak_authorize_url') || discovery_object['authorization_endpoint'] || "#{realm_url}/protocol/openid-connect/auth"
  end # #authorize_url

  def realm
    env_value('keycloak_realm') || @_oidc['realm']
  end # #realm

  def scope
    env_value('keycloak_scope') || @scope
  end # #scope

  def server_prefix
    env_value('keycloak_server_prefix') || ''
  end

  def realm_url
    URI.join(url, "#{server_prefix}/realms/", "#{realm}").to_s
  end # #realm_url

  def token_endpoint
    env_value('keycloak_token_endpoint') || discovery_object['token_endpoint'] || "#{realm_url}/protocol/openid-connect/token"
  end # #token_endpoint

  def disable_rack=(value)
    self.client_only = value
  end # #disable_rack=

  # Omniauth URL where the authentication starts.
  # it's ussually /auth/:provider
  def omniauth_provider_post_path
    env_value('omniauth_provider_post_path') || '/auth/keycloak'
  end

  ##
  # parameter:
  # * segments      admin funcitonality which will used, e.g. users
  def admin_api(segment)
    URI.join(url, "#{server_prefix}/admin/realms/", "#{realm}/", segment).to_s
  end # #admin_api

  protected

  def env_value(key)
    ENV["#{@config_prefix}#{key}"]
  end
end
