Rails.application.routes.draw do
  get '/auth/keycloak/callback' => 'omniauth_keycloak/callback#callback'

#namespace :omniauth_keycloak do
# resource :session, only: [] do
#   collection do
#     get :login_user,  as: 'login'
#     get :logout_user, as: 'logout'
#   end
# end
#end

  get '/login' => 'omniauth_keycloak/sessions#login_user'
  get '/logout' => 'omniauth_keycloak/sessions#logout_user', as: :session

  #get '/session_logout' => 'omniauth_keycloak/sessions#logout_session'

  post '/k_push_not_before' => 'omniauth_keycloak/callback#revoke'
  post '/k_logout' => 'omniauth_keycloak/callback#logout_user_callback'
end
