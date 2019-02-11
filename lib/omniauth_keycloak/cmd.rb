##
#
# This module includes calls from the keycloak admin api.
#
# If you add another call, you can debig with the setting of :debug_output => $stdout into httparty options
#
# Also take a look at the documentation:
#
# https://www.keycloak.org/docs-api/4.1/rest-api/index.html#_users_resource
#
module OmniauthKeycloak::Cmd
  class << self
    def create_user(username, password)
      OmniauthKeycloak.log("Create user on #{OmniauthKeycloak.config.admin_api('users')}")
      response = HTTParty.post(OmniauthKeycloak.config.admin_api('users'), { 
          body: {
            username:     username, 
            email:        username,
            credentials:  [{type: 'password', value: password}],
            enabled:      true
          }.to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json'
          } 
        }
      )

      if response.headers['location'].present? 
        return response.headers['location'].split('/').last
      else
        OmniauthKeycloak.log("Could not create #{response.to_json}")
        return nil
      end
    end # .create_user


    def user_send_actions_email(user_id, redirect_uri = 'http://localhost:3000' )
      HTTParty.put(
        OmniauthKeycloak.config.admin_api(
          "users/#{user_id}/execute-actions-email?redirect_uri=#{redirect_uri}&client_id=#{OmniauthKeycloak.config.client_id}"
        ), { 
          body: ['UPDATE_PASSWORD'].to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json'
          }
        }
      )
    end # .trigger_user_action_mail

    def user_send_verify_email(user_id, redirect_uri = 'http://localhost:3000' )
      HTTParty.put(
        OmniauthKeycloak.config.admin_api(
          "users/#{user_id}/send-verify-email?redirect_uri=#{redirect_uri}&client_id=#{OmniauthKeycloak.config.client_id}"
        ), { 
          body: {
            redirect_uri: redirect_uri
          }.to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json'
          } 
        }
      )
    end # .trigger_user_action_mail



    ######################
    ##  Helper Methods  ##
    ######################


    def user_id_by_email(email)
      response = HTTParty.get(
        OmniauthKeycloak.config.admin_api("users?email=#{CGI::escape(email)}"), { 
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json'
          } 
        }
      ).parsed_response
      if response.present? and response.length > 0
        return response.first['id']
      else
        return nil
      end
    end # .user_id_by_email

    def required_actions
      HTTParty.get(
        OmniauthKeycloak.config.admin_api("authentication/required-actions"), { 
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type'  => 'application/json'
          } 
        }
      ).parsed_response
    end # .required_actions

    private

    def access_token
      OmniauthKeycloak::KeycloakToken.client_credentials.token
    end # #access_token
  end # class << self
end
