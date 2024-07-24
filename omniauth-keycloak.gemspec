Gem::Specification.new do |s|
  s.name        = 'omniauth-keycloak'
  s.version     = File.open('VERSION').read.strip
  s.date        = '2016-06-16'
  s.summary     = 'Omniauth strategy for Keycloak authentification'
  s.description = ' test'
  s.authors     = ['Markus Altmeyer', 'Matthias Folz']
  s.email       = 'maltmeyer@avarteq.de'
  s.homepage    = 'https://github.com/avarteqgmbh/omniauth-keycloak'
  s.license       = 'propitary'
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.files         = `git ls-files`.split("\n")

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.0.0'

  s.add_dependency 'httparty'
  s.add_dependency 'jwt'
  s.add_dependency 'nokogiri', '>= 1.16.5'
  s.add_dependency 'omniauth', '>= 2.1.2'
  s.add_dependency 'omniauth-oauth2', '>= 1.8.0'
  s.add_dependency 'rack', '>= 2.2.8.1'

  s.add_development_dependency 'rails', '>=  6.1.7.8'
  s.add_development_dependency 'rexml', '>= 3.3.2'

  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'listen', '2.10.1'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
end
