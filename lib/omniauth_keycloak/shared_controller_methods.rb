module OmniauthKeycloak::SharedControllerMethods

  protected

  def get_token(request)
    token = request.headers['HTTP_AUTHORIZATION']
    token = nil if token.present? and token.include?('Basic')
    token ||= request.params['api_key']

    if token
      token['Bearer'] = '' if token.include?("Bearer")
      token = token.strip
      token = OmniauthKeycloak::KeycloakToken.new(token)
      OmniauthKeycloak.log("Request from: #{token.sub}")
      token
    else
      nil
    end
  end

  def check_client_roles_api(token)
    (token.client_roles & OmniauthKeycloak.config.allowed_client_roles_api).count > 0
  end

  def check_realm_roles_api(token)
    (token.realm_roles & OmniauthKeycloak.config.allowed_realm_roles_api).count > 0
  end

end
