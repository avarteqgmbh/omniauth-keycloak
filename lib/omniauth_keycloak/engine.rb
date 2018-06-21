class OmniauthKeycloak::Engine < ::Rails::Engine
  isolate_namespace OmniauthKeycloak


  initializer "omniauth_keycloak.middleware" do |app|

    unless OmniauthKeycloak.config.client_only 
      OmniauthKeycloak.register_rack(app.config.middleware)
    end
  end # initializer
end
