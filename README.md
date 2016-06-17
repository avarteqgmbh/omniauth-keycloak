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


