# omniauth-keycloak


## Installation

Just add the gem to your gemfile
```ruby
gem 'omniauth-keycloak'
```

Configure omniauth in config/initializers/omniauth.rb
```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :keycloak, ENV["keycloak_client_id"], ENV["keycloak_client_secret"], scope: "openid", public_key: ENV["keycloak_public_key"],client_options: {:site => ENV["keycloak_url"], :authorize_url => ENV["keycloak_authorize_url"], :token_url => ENV["keycloak_token_endpoint"]}
end
```

To use this gem you have to provide the env variables listet above. To do this, you can use the Figaro gem for example.

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
        :site          => ENV["keycloak_url"],·                  
        :authorize_url => ENV["keycloak_authorize_url"],·         
        :token_url     => ENV["keycloak_token_endpoint"]               
      }                                                           
    })                                                            
```

Add route for callback e.g:

```ruby
get '/auth/keycloak/callback' => 'application#callback'
```
Start the authentication by redirecting the user to /auth/keycloak
```ruby
redirect_to "/auth/keycloak" 
```


You can use the class KeycloakToken for easy AccessToken handling:

```ruby
begin
  access_token = env['omniauth.auth']['credentials']['token'] #get acces Token from omniauth in callback
  keycloak_token = OmniauthKeycloak::KeycloakToken.new(access_token)
rescue JWT::VerificationError
  #Signature verification raised
end
```   

To verify if an Token is valid:
```ruby
begin
      nonce = env['omniauth.auth']['info']['original_nonce']
      keycloak_token.verify!(:issuer => "issuer", :client_id => "clientid", nonce: nonce)
rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
end
``` 
If no options are passed to verify, the values from env will be used. (issuer will be ENV[keycloak_url])

Get JWT claims:
```ruby
 keycloak_token.sub
 keycloak_token.exp
 ...
``` 

Get custom user attributes:
```ruby
 keycloak_token.attributes['name']
``` 

Get original token:
```ruby
  keycloak_token.token
``` 

Get roles:
```ruby
  keycloak_token.roles #get user roles from current client and realm roles 
  keycloak_token.roles_hash  # returns hash with clientname => roles for all clients
  keycloak_token.role?(role_name,use_realm_roles = false) #check if role exist, with or without realm roles
  keycloak_token.client_roles # get all user roles for this client
  keycloak_token.realm_roles # get all realm roles
```

Send request with Token (See omniauth2 gem for other http methods):
```ruby
  keycloak_token.oauth2token.get(url).body
```

Get Token with client credentials grant type (omniauth strategy is not used):
```ruby
  begin
    token = OmniauthKeycloak::KeycloakToken.client_credentials
  rescue JWT::VerificationError
    #Signature verification raised
  end
```


Refresh Access Token with RefreshToken:

```ruby
keycloak_token.refresh_token = env['omniauth.auth']['credentials']['refresh_token'] #set refresh Token

keycloak_token.expired? #check if access token is expired

begin
          new_token = keycloak_token.refresh
rescue OAuth2::Error => e
          #Refresh Token or keycloak session expired, use strategy again to get access token
rescue JWT::VerificationError => e
          #Signature verification raised
end

```


