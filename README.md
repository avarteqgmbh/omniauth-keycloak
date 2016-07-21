# omniauth-keycloak


## Installation

Just add the gem to your gemfile
```ruby
gem 'omniauth-keycloak'
```

If you use devise, specify the Keycloak Server within the initializer:

```ruby
Devise.setup do |config|                                          
                                                                  
  config.omniauth(                                                
    :keycloak,·                                                   
    ENV["keycloak_client_id"],·                                   
    ENV["keycloak_client_secret"], {                              
      scope:          "openid",·                                  
      public_key:     ENV["keycloak_public_key"],                 
      client_options: {                                           
        :site          => ENV["keycloak_site"],·                  
        :authorize_url => ENV["keycloak_authorize_url"],·         
        :token_url     => ENV["keycloak_token_url"]               
      }                                                           
    })                                                            
```

You can use the class KeycloakToken for easy access token handling:

```ruby
keycloak_token = OmniauthKeycloak::KeycloakToken.new(
env['omniauth.auth']['credentials']['token'],
keycloak_public_key)
```   

To verify if an Token is valid:
```ruby
begin
      nonce = env['omniauth.auth']['info']['original_nonce']
      keycloak_token.verify!(:issuer => "issuer", :client_id => "clientid", nonce: nonce)
rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
end
``` 

Get user attributes:
```ruby
 keycloak_token.attributes['name']
``` 

Get original token:
```ruby
  keycloak_token.token
``` 
Get roles:
```ruby
  keycloak_token.roles  # returns hash with clientname => roles
  keycloak_token.role?("client_name"," role_name",use_realm_roles = false) #check if role exist, with or without realm roles
  keycloak_token.client_roles("clientname") # get all user roles on this client
  keycloak_token.realm_roles # get all realm roles
```




