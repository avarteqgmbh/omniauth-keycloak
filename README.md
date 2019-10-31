# OmniauthKeycloak

## Installation

You can install the Keycloak Client as OmniAuth Strategy to integrate it.
This is usefull to operate with devise.

Or you can use it as Standalone authentification if you want to use Keycloak only authentifications.


## Authentication with Keycloak account

After you integrate OAuth in your service successfully, you can authenticate  with your keycloak account.
You don't need to set up a new database, you can still use the old database. 
The implementation matches up the email from your keycloak account with your service account.


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

# Getting started with devise

Add the ```omniauth-keycloak``` gem to the Gemile of your application. It's important that the gem is above the ```devise``` gem line in the Gemfile. Otherwise it would throw a ```configure_warden!``` error.

```ruby
gem 'omniauth-keycloak',  git: 'git@github.com:avarteqgmbh/omniauth-keycloak.git'
gem 'devise'    # add devise after omniauth-keycloak 

```

Then run ```bundle install```

Next, you need to add the 2 columns "provider" (string) and "uid" (string) to your ```User``` model (use the class name for the application's users). 
You can generate the migration with 

```ruby
rails g migration AddOmniauthToUsers provider:string uid:string
```
and run ```rake db:migrate``` after that.

After the migration, you need to add the omniauth option for devise to your model in  ```app/models/user.rb```:

```ruby
devise ..., :omniauthable
```

Also mount the engine into your ```routes.rb```. If the routes are not loaded automatically, then add ```OmniauthKeycloak.config.load_routes``` to load the routes from the engine. Add ```controllers: { omniauth_callbacks: 'omniauth_callback' }``` to ```devise_for```, because the standard callback method from the omniauth-keycloak engine does not work with Devise.

```ruby
mount OmniauthKeycloak::Engine  => '/auth'
devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callback' }
```

Next create a new view for the login with Keycloak ```view/devise/sessions/new.html.erb```

```ruby
<%- if devise_mapping.omniauthable? %>
  <%- resource_class.omniauth_providers.each do |provider| %>
    <%= link_to "Sign in with #{provider.to_s.titleize}", omniauth_authorize_path(resource_name, provider) %><br />
  <% end -%>
<% end -%>
```

After this, we need to overwrite the controller from the engine for the callbacks in ```app/controllers/omniauth_callback_controller.rb```. The reason is that the standard controller from omniauth-keycloak dont have a user association.

```ruby
class OmniauthCallbacksController < Devise::OmniauthCallbackController
  include OmniauthKeycloak::OmniauthControllerExtension
  skip_before_filter :authenticate
  def callback
    acess_token 		= env['omniauth.auth']['credentials']['token']
    nonce           = env['omniauth.auth']['info']['original_nonce']
    refresh_token   = env['omniauth.auth']['credentials']['refresh_token']

    user = User.from_omniauth(auth_hash)

    begin
      token = OmniauthKeycloak::KeycloakToken.new(acess_token)
      token.verify!(nonce: nonce)

      if check_client_roles(token) or check_realm_roles(token)
        login(token,refresh_token)
        OmniauthKeycloak.log('Redirect after login')
        if OmniauthKeycloak.config.login_redirect_url
          sign_in_and_redirect :user, user
        else
          sign_in :user, user
          redirect_to main_app.root_path
        end
      else
        OmniauthKeycloak.log('Access denied')
        flash.now[:error] = "Access denied"
        render :template => 'layouts/error'
      end

    rescue OmniauthKeycloak::KeycloakToken::InvalidToken => e
      OmniauthKeycloak.log(e)
      flash[:error] = "#{e}"
      render :template => 'layouts/error'
    end
  end

  alias_method :keycloak, :callback

  def failure;  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end
end
```

Finally, we need to implementent the from_omniauth method in the user model to find the user ```app/models/user.rb```. The user has to be present beacuse Keycloak should not create new user for the client.

```ruby
def from_omniauth(auth)
  user = where(email: auth.info.email).first || where(auth.slice(:provider, :uid).to_h).first 
  user.tap do |this|
    this.update_attributes(
      provider: auth.provider,
      uid: auth.uid, 
      email: auth.info.email)
  end
end
```

Also add this method in ```app/models/user.rb``` to override the password requirement from Devise:

```ruby
def password_required?
  return false if provider.present?
end
```

## Configuration with gem "envyable"

Next up, you need to declare the Keycloak provider and also add the initializer for the OIDC-JSON in ```config/initializers/devise.rb```:

```ruby
OmniauthKeycloak.init( $AddYourJsonHere$ ) do |config|
  config.allowed_realm_roles  = [ $AddYourRolesHere$ ]
  config.token_cache_expires_in = 10.minutes
  config.disable_rack = true
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

Add for $AddYourJsonHere$ and $AddYourRolesHere$ the environment variable name for the OIDC-JSON from Keycloak and your defined roles.
All necessary informations are loaded from the environment variable by the ```omniauth-keycloak``` engine.

### env.yml Example

Example for environment file as ```env.yml```:

```yaml
keycloak_oidc_json: OIDC-JSON from Keycloak

keycloak_public_key: public key from Keycloak

allowed_roles: "your defined role"
```

If you allow more than one role, you can add your roles as Json to your ```env.yml```:

```yaml
allowed_roles: '{
  "realm_roles": [ $AddYourRolesHere$ ]
}'
```

Change the config loading line in the ```config/initializers/devise.rb``` to:
```ruby
config.allowed_realm_roles  = JSON.parse(ENV['allowed_roles'])['realm_roles']
```

## CSRF Protection

The request phase of the OmniAuth Ruby gem is vulnerable to Cross-Site Request Forgery when used as part of the Ruby on Rails framework. See [CVE-2015-9284](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-9284)

Therefore we need to add an csrf protection gem to prevent this vulnerability: 
https://github.com/cookpad/omniauth-rails_csrf_protection

```ruby
gem "omniauth-rails_csrf_protection"
```

Then run ```bundle install```. Then update all links to ```/auth/:provider``` to use a POST request. 

```ruby
<%= link_to "Sign in with #{provider.to_s.titleize}", omniauth_authorize_path(resource_name, provider), method: :post %><br />
```

See the [Dokumentation](https://github.com/omniauth/omniauth/wiki/Resolving-CVE-2015-9284) form the gem for more details.

## Troubleshooting

### Cookie size overflow

If you got problems with the cookie size, change the ```:cookie_store``` to ```:active_record_store``` in ```config/initializers/session_store.rb```.

```ruby
FancyVacations::Application.config.session_store :active_record_store, :key => '_your_app_session'
```

Include the ´´´gem 'activerecord-session_store'´´´ into your Gemfile: 

```ruby
gem 'activerecord-session_store'
```

Run the migration generator for active_record and then run the migration:

```ruby
rails g active_record:session_migration
```

Run ```rake db:migrate``` after the migration.


### Development with Ruby-2.6.0 and Rails-6.0.0

#### Spring

If you get undefined method error for the OmniauthCallbackController. Then try to restart Spring with ```spring stop```. Then start your server again.

#### before_action

For services with older ruby and rails version we need to keep the class method before_filter. For newer version you need to replace these methods with before_action syntax. See [StackOverflow](https://stackoverflow.com/questions/16519828/rails-4-before-filter-vs-before-action) entry.
