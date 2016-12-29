# OmniauthKeycloak

## Installation

### Rails

Add following initializer.
Take the OIDC-JSOn from Keycloak.
Also define the Public key from keycloak under the env variable.
```keycloak_public_key```

```ruby
OmniauthKeycloak.init( <OIDC-JSON> ) do |config|
  config.allowed_realm_roles  = ['Admin']
  config.allowed_client_roles = ['admin']
  config.token_cache_expires_in = 10.minutes
  config.allowed_client_roles_api =['admin']
  config.allowed_realm_roles_api  =['admin']
end
```


Mount the engine into your routes.rb
You will maybe cover old views with session_path helpers.

```
get    'logout', to:'omniauth_keycloak/sessions#logout_user', as: 'session'
delete 'logout', to:'omniauth_keycloak/sessions#logout_user', as: 'session'
mount OmniauthKeycloak::Engine  => '/auth'
```
