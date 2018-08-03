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


If you got Problems with *omniauth_keycloak/application_controller not found*
configure the eager_load_path in config/application.rb as follow:

```
  config.eager_load_paths += %W( #{OmniauthKeycloak.config.root}/app/controllers )
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

### Getting started with devise

Add the OmniAuth gem to the Gemile of your application:

```ruby
gem 'omniauth-keycloak'
```

Then run ```bundle install```

Next, you need to add the 2 columns "provider" (string) and "uid" (string) to your ```User``` model (use the class name for the application's users). 
You can generate the migration with 

```ruby
rails g migration AddOmniauthToUsers provider:string uid:string
```
and run ```rake db:migrate``` after that.

Next up, you need to declare the Keycloak provider and also add the initializer for the OIDC-JSON in ```config/initializers/devise.rb```:

```ruby
OmniauthKeycloak.init( ENV["<OIDC-JSON>"] ) do |config|
  config.allowed_realm_roles  = [ <ROLES> ]
  config.allowed_client_roles = [ <ROLES> ]
  config.token_cache_expires_in = 10.minutes
  config.allowed_client_roles_api =[ <ROLES> ]
  config.allowed_realm_roles_api  =[ <ROLES> ]
end

config.omniauth(:keycloak, OmniauthKeycloak.config.client_id, OmniauthKeycloak.config.client_secret, {
    scope:      OmniauthKeycloak.config.scope,
    public_key: OmniauthKeycloak.config.public_key, 
    client_options: {
      site:          OmniauthKeycloak.config.url,
      authorize_url: OmniauthKeycloak.config.authorize_url,
      token_url:     OmniauthKeycloak.config.token_endpoint
    }
  })
```

Add for <OIDC-JSON> the environment variable name for the OIDC-JSON from Keycloak and define the allowed roles in <ROLES>.
All necessary informations are loaded from the environment variable by the ```omniauth-keycloak``` engine.

Example for environment file as ```env.yml```:

```yaml
keycloak_oidc_json: OIDC-JSON from Keycloak

keycloak_public_key: public key from Keycloak
```

After configuring your strategy, you need to add the omniauth option to your model in  ```app/models/user.rb```:

```ruby
devise :omniauthable
```

Also mount the engine into your ```routes.rb```

```ruby
mount OmniauthKeycloak::Engine  => '/auth'
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
devise_scope :user do
  get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
  get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
end
```

Next, create a new view for the login with Keycloak ```view/user/devise/sessions/new.html.erb``` ("user" is the name of our user model) 

```ruby
<%- if devise_mapping.omniauthable? %>
  <%= link_to "Sign in with Keycloak", user_omniauth_authorize_path(provider) %>
<% end -%>
```

After this, we need to create a controller for the callbacks in ```app/controllers/omniauth_callbacks_controller.rb```

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthKeycloak::CallbackController
end
```

Finally, we need to implementent the from_omniauth method in the user model to find or create the user ```app/models/user.rb```

```ruby
class << self
  def from_omniauth(auth)
    user = where(email: auth.info.email).first || where(auth.slice(:provider, :uid).to_h).first || new
    user.tap do |this|
      this.update_attributes(
        provider: auth.provider,
        uid: auth.uid, 
        email: auth.info.email)
    end
  end
end
```

#### Cookie size overflow

If you got problems with the cookie size, change the ```:cookie_store```to ```:active_record_sotre``` in ```config/initializers/session_store.rb```

´´´ruby
FancyVacations::Application.config.session_store :active_record_store, :key => '_fancy_vacations_session'
´´´

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
