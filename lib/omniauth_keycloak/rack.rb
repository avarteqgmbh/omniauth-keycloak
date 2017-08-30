class OmniauthKeycloak::Rack < Rack::Auth::AbstractHandler
  include OmniauthKeycloak::SharedControllerMethods

  def call(env)
    request = { headers: env }
    token = get_token(OpenStruct.new(request))

    if token and check_client_roles_api(token) and check_realm_roles_api(token)
      return @app.call(env)
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
