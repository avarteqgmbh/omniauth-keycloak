require 'spec_helper'

describe 'OmniauthKeycloak::Configuration' do

  describe 'Keycloak url detection' do
    context 'without auth/ in url' do
      it 'should return correct url without auth/ in url' do
        expect(OmniauthKeycloak::Configuration.new.realm_url).to eq('http://localhost-test.de/realms/')
      end
    end 

    context 'with auth/ in url' do
      before do
        ENV['keycloak_server_prefix'] ='auth'
      end

      after do
        ENV.delete('keycloak_server_prefix')
      end

      it 'should return correct url with auth/ in url' do
        expect(OmniauthKeycloak::Configuration.new.realm_url).to eq('http://localhost-test.de/auth/realms/')
      end
    end
  end

end