require 'spec_helper'


describe 'OmniauthKeycloak::KeycloakToken' do

  context 'with public_key' do
    before do
      OmniauthKeycloak.config.stub(:public_key).and_return('124')
      ENV['keycloak_public_key'] ='1234567'
    end

    it 'should raise an OpenSSL error on invalid data' do
      expect { OmniauthKeycloak::KeycloakToken.new('123456') } .to raise_error(OpenSSL::PKey::RSAError)
    end

    it 'should not raise InvalidToken if initialized with nil' do
      expect { OmniauthKeycloak::KeycloakToken.new(nil) } .to raise_error(OmniauthKeycloak::KeycloakToken::InvalidToken)
    end
  end # context 'with public_key'

  context 'without public_key' do
    before do
      OmniauthKeycloak.config.stub(:public_key).and_return(nil)
    end
    it 'should raise InvalidSetup exception' do
      expect { OmniauthKeycloak::KeycloakToken.new(nil) }.to raise_error(OmniauthKeycloak::KeycloakToken::InvalidSetup) 
    end
  
  end # context 'without public_key'
end
