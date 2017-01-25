OmniauthKeycloak::Engine.routes.draw do
  get '/auth/keycloak/callback' => 'callback#callback'
  get '/keycloak/callback' => 'callback#callback'

  get '/login'  => 'sessions#login_user'
  delete '/logout' => 'sessions#logout_user' 
  delete '/logout' => 'sessions#logout_user', as: :session

  post   '/k_push_not_before' => 'callback#revoke'
  post   '/k_logout'          => 'callback#logout_user_callback'
end
