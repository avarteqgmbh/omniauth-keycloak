Rails.application.routes.draw do
#OmniauthKeycloak::Engine.routes.draw do
  get '/auth/keycloak/callback' => 'callback#callback'

  get '/login' => 'sessions#login_user'
  get '/logout' => 'sessions#logout_user'
  get '/session_logout' => 'sessions#logout_session'

  post '/k_push_not_before' => 'application#revoke'
  post '/k_logout' => 'application#logout_user_callback'
end
