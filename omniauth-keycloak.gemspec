
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
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.files         = `git ls-files`.split("\n")

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ['lib']
  s.add_dependency 'omniauth-oauth2', '~> 1.3.1'
  s.add_dependency 'jwt'
  s.add_dependency 'httparty'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'rails'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'guard-bundler'
  s.add_development_dependency 'listen', '2.10.1'

end
