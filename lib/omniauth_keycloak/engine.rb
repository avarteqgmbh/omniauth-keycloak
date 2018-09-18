
class OmniauthKeycloak::Engine < ::Rails::Engine
  isolate_namespace OmniauthKeycloak


  initializer "omniauth_keycloak.middleware" do |app|
    OmniauthKeycloak.log('Register OmniauthEngine')

    unless OmniauthKeycloak.config.client_only 
      OmniauthKeycloak.register_rack(app.config.middleware)
    end
    app.config.eager_load_paths += [File.expand_path('../../../app/controllers',__FILE__)]
  end # initializer
end
