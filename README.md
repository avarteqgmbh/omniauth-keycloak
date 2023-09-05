# OmniauthKeycloak

## Description

Omniauth-keycloak is an authentication and authorization library for Ruby on Rails which use the OAuth 2.0 and OIDC protocol.

## Table of Contents
- [Installation](#installation)
  - [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [Keycloak Setup](docs/keycloak_setup.md)
  - [Rails Setup](docs/rails_setup.md)
- [Known issues](#known-issues)


## Installation

You can use the libarary as standalone authentification if you want to use Keycloak only authentifications. The libarary is also usable with the [devise](https://github.com/heartcombo/devise) gem.

### Requirements

  * [Keycloak](https://www.keycloak.org/)
  * Rails application

## Getting Started

Add the OmniAuth gem to the Gemile of your application:

```ruby
gem 'omniauth-keycloak', git: 'git@github.com:avarteqgmbh/omniauth-keycloak.git'
```

Before you continue with the Rails setup, you also need get the `public_key` and the client `oidc_json` from Keycloak. The full Keycloak confguration is documented in Keycloak documentation section.

Keycloak Setup: [Documenation](docs/keycloak_setup.md)

After you have everything ready in Keycloak you can begin the Rails setup.

Rails Setup: [Documentaton](docs/rails_setup.md)

## Known issues

 * JWKS Support not Implemented
 * No autoamtic lookup after OAuth2 End Points
