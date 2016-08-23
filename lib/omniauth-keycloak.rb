
require File.expand_path('../strategy', __FILE__)
require File.expand_path('../keycloak_token', __FILE__)
module OmniauthKeycloak

  autoload :Config, File.expand_path('../omniauth-keycloak/config', __FILE__)

   class << self
     def config
       @config ||= OmniauthKeycloak::Config.new
     end
   end

end
