class OmniauthKeycloak::Rack < Rack::Auth::AbstractHandler
  include OmniauthKeycloak::SharedControllerMethods

  def call(env)
    request = { headers: env, params: Rack::Request.new(env).params}
    token = get_token(OpenStruct.new(request))

    if token 
      unless check_client_roles_api(token) or check_realm_roles_api(token)
        OmniauthKeycloak.log("Allowed Roles #{OmniauthKeycloak.config.allowed_realm_roles_api | OmniauthKeycloak.config.allowed_client_roles_api}")
        OmniauthKeycloak.log("Token Roles:\n\t#{token.roles * "\n\t"}")
        OmniauthKeycloak.log('Access denied')
        unauthorized
      else
        return @app.call(env)
      end
    else
      unauthorized
    end
  end

  private

  def challenge
    'Bearer realm="%s"' % realm
  end

  def valid?(auth)
    @authenticator.call(*auth.credentials)
  end

end
