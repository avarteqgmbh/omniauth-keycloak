
require File.expand_path('../strategy', __FILE__)
require File.expand_path('../keycloak_token', __FILE__)
require File.expand_path('../controller_extension',__FILE__)
require File.expand_path('../omniauth_controller_extension',__FILE__)
require File.expand_path('../api_controller_extension',__FILE__)
require 'omniauth-keycloak/engine'

module OmniauthKeycloak

  autoload :Config, File.expand_path('../omniauth-keycloak/config', __FILE__)

   class << self
     def config
       @config ||= OmniauthKeycloak::Config.new
     end
   end

end
