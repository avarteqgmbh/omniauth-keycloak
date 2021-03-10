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
    def get_clients
      general_get(
        OmniauthKeycloak.config.admin_api('clients')
      )
    end

    def get_client_roles(id)
      general_get(
        OmniauthKeycloak.config.admin_api("clients/#{id}/roles")
      )
    end

    def get_users
      general_get(
        OmniauthKeycloak.config.admin_api('users')
      )
    end

    def get_user_groups(id)
      general_get(
        OmniauthKeycloak.config.admin_api("users/#{id}/groups")
      )
    end

    def get_user_roles(user_id)
      general_get(
        OmniauthKeycloak.config.admin_api("users/#{user_id}/role-mappings/realm/composite")
      )
    end

    def get_user_role_mapping(id)
      general_get(
        OmniauthKeycloak.config.admin_api("users/#{id}/role-mappings")
      )
    end

    def create_user(username, password)
      OmniauthKeycloak.log("Create user on #{OmniauthKeycloak.config.admin_api('users')}")
      response = HTTParty.post(OmniauthKeycloak.config.admin_api('users'), {
                                 body: {
                                   username: username,
                                   email: username,
                                   credentials: [{ type: 'password', value: password }],
                                   enabled: true
                                 }.to_json,
                                 headers: {
                                   'Authorization' => "Bearer #{access_token}",
                                   'Content-Type' => 'application/json'
                                 }
                               })

      if response.headers['location'].present?
        response.headers['location'].split('/').last
      else
        OmniauthKeycloak.log("Could not create #{response.to_json}")
        nil
      end
    end

    def user_send_actions_email(user_id, redirect_uri = 'http://localhost:3000')
      HTTParty.put(
        OmniauthKeycloak.config.admin_api(
          "users/#{user_id}/execute-actions-email?redirect_uri=#{redirect_uri}&client_id=#{OmniauthKeycloak.config.client_id}"
        ), {
          body: ['UPDATE_PASSWORD'].to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        }
      )
    end

    def user_send_verify_email(user_id, redirect_uri = 'http://localhost:3000')
      HTTParty.put(
        OmniauthKeycloak.config.admin_api(
          "users/#{user_id}/send-verify-email?redirect_uri=#{redirect_uri}&client_id=#{OmniauthKeycloak.config.client_id}"
        ), {
          body: {
            redirect_uri: redirect_uri
          }.to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        }
      )
    end

    ######################
    ##  Helper Methods  ##
    ######################

    def general_get(url)
      HTTParty.get(
        OmniauthKeycloak.config.admin_api(url),
        {
          body: {
          }.to_json,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        }
      )
    end

    def user_id_by_email(email)
      response = HTTParty.get(
        OmniauthKeycloak.config.admin_api("users?email=#{CGI.escape(email)}"), {
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        }
      ).parsed_response
      response.first['id'] if response.present? && (response.length > 0)
    end

    def required_actions
      HTTParty.get(
        OmniauthKeycloak.config.admin_api('authentication/required-actions'), {
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => 'application/json'
          }
        }
      ).parsed_response
    end

    private

    def access_token
      OmniauthKeycloak::KeycloakToken.client_credentials.token
    end
  end
end
