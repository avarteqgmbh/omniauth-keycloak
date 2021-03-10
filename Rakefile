require 'active_support/all'
require File.expand_path('spec/dummy/config/environment.rb', __dir__)
Bundler.require(:default, Rails.env) if defined?(Bundler)
require './init'

require 'csv'

task :list_users do
  OmniauthKeycloak.init(
    File.read('./keycloak.json')
  )

  generate_csv
end

def generate_csv
  result = CSV.open('users.csv', 'w+') do |csv|
    csv << [
      'Email',
      'Group',
      'Roles',
      'Direct assigned Roles',
      'Clients'
    ]
    OmniauthKeycloak::Cmd.get_users.select do |users_hash|
      users_hash['enabled']
    end.each do |user_hash|
      groups       = OmniauthKeycloak::Cmd.get_user_groups(user_hash['id'])
      roles        = OmniauthKeycloak::Cmd.get_user_roles(user_hash['id'])
      client_mappings = OmniauthKeycloak::Cmd.get_user_role_mapping(user_hash['id'])['clientMappings']

      client_roles = client_mappings.values.map { |client| client_mapping_to_roles(client) }

      clients = []

      csv << [
        user_hash['email'],
        groups.map { |g| g['name'] } * "\n",
        roles.map { |g| g['name'] } * "\n",
        client_roles * "\n",
        clients * "\n"

      ]
    end
  end

  puts result
end

def client_mapping_to_roles(client_mapping)
  client_roles = []
  return client_roles if client_mapping['mappings'].nil?

  client_mapping['mappings'].each do |role|
    client_roles << "#{client_mapping['client']}.#{role['name']}"
  end
  client_roles
end
