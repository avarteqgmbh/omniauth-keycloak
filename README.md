# OmniauthKeycloak

## Installation

You can install the Keycloak Client as OmniAuth Strategy to integrate it.
This is usefull to operate with devise.

Or you can use it as Standalone authentification if youw ant to use Keycloak only authentifications.

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


## Secure API Calls between services

You have different possibilities to authenticate one api service to another.

### Request Token to make Calls

Create a own full user for this calls and authenticate with user and password:
```ruby
token = OmniauthKeycloak::KeycloakToken.password(<user>,<password>)
```
Or

Use the Client Credentials to get a token.
Therefore you must activate the *Service Account*-Feature in the client settings.
You are also able to assign Roles to the Service accounts to ristrict the Service2Service access the same way.

```ruby
token = OmniauthKeycloak::KeycloakToken.client_credentials
```


### Client Integration

The usage is very simple.
Install the omniauth-keycloak gem and use the Token-Client to generate a Bearer Token.

You must send this Token into the Authorization Header in Every HTTP Request

```Ruby
class Fancyness < ActiveResource::Base

  self.site     = 'https://test.avarteq.de'

  def self.create_fancy_stuff
    self.headers['Authorization'] = "Bearer #{OmniauthKeycloak::KeycloakToken.client_credentials.token}"
    response = self.create(:identifier => :disable_anynines_organization, :init_payload => organization.to_h)
  ....

```

### Server Integration

Just include the ```OmniauthKeycloak::ApiControllerExtension``` into the API Base Controller.

Don't forget to set the allowed roles for API Access into the initializer.
