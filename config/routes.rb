Rails.application.routes.draw do
  get '/auth/keycloak/callback' => 'omniauth_keycloak/callback#callback'

  get '/login' => 'omniauth_keycloak/sessions#login_user'
  get '/logout' => 'omniauth_keycloak/sessions#logout_user'
  get '/session_logout' => 'omniauth_keycloak/sessions#logout_session'

  post '/k_push_not_before' => 'omniauth_keycloak/sessions#revoke'
  post '/k_logout' => 'omniauth_keycloak/session#logout_user_callback'
end
