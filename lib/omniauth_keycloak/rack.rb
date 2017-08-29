class OmniauthKeycloak::Rack < Rack::Auth::AbstractHandler
  include OmniauthKeycloak::SharedControllerMethods

  def call(env)
    token = get_token(env.request)

    if token and check_client_roles_api(token) and check_realm_roles_api(token)
      return @app.call(env)
    else
      unauthorized
    end
  end

end
