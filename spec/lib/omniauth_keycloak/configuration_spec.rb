require 'spec_helper'

describe 'OmniauthKeycloak::Configuration' do

  describe 'Keycloak url detection' do
    context 'without auth/ in url' do
      before do
        ENV["keycloak_url"] = 'http://auth-test.anynines.com/'
      end

      it 'should return correct url without auth/ in url' do
        expect(OmniauthKeycloak::Configuration.new.realm_url).to eq('http://auth-test.anynines.com/realms/')
      end
    end 

    context 'with auth/ in url' do
      before do
        ENV["keycloak_url"] = 'http://auth-test.anynines.com/'
        ENV['keycloak_server_prefix'] ='auth'
      end

      it 'should return correct url with auth/ in url' do
        expect(OmniauthKeycloak::Configuration.new.realm_url).to eq('http://auth-test.anynines.com/auth/realms/')
      end
    end 
  end

end