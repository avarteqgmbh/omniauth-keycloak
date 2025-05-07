# Changelog
### 3.5.1 -  2025-05-07
* fix Rails.cache.fetch compatibiltiy with newer rails version when key is nil

### 3.5.0 -  2025-04-07
* Bump gems affected by CVEs (#23)
* Feature/int 4538 remove nonce claim from access token (#22)

### 3.4.0 -  2025-03-26
* bump gems affected by cves (#21)
* Bump gems affected by CVEs (#23)

### 3.3.0 -  2024-11-20
* bump gems affected by cves (#21)

### 3.2.0 -  2024-10-15
* feature/INT-4515_fix_CVE-s (#20)
* bump version

### 3.1.0 -  2024-07-25
* Update Readme and documentation (#14)
* fix high and moderate cves (#15)

### 3.0.1 -  2024-03-27
* make post-url for providers configurable

### 3.0.0 -  2023-09-05
* Feature/int 3092 remove auth from url (#13)
* Update Readme and documentation (#14)

### 2.2.0 -  2023-02-07
* Feature/int 2283 discovery object rescue (#11)
* update gems affected by CVEs (#12)

### 2.1.0 -  2022-10-08
* BUM-7600 Remove: autoloading routes (#9)
* update to omniauth 2 and omniauth-oauth 1.8 (#10)
* Feature/int 2283 discovery object rescue (#11)

### 2.0.0 -  2022-09-01
* BUM-7600 Remove: autoloading routes (#9)
* update to omniauth 2 and omniauth-oauth 1.8 (#10)

### 1.5.0 -  2022-08-04
* INT-2030 add discovery_url (#7)
* BUM-7600 Remove: autoloading routes (#9)

### 1.4.1 -  2022-06-23
* WiP fix bundle setup & rspec
* fix rspec tests
* adjust test environment check and token endpoint url
* apply change request after code review
* remove test environment check

### 1.4.0 -  2022-04-21
* Feature/user management (#2)
* INT-2030 add discovery_url (#7)

### 1.3.10 -  2022-04-07
* remove jsons
* extend gitignore

### 1.3.9 -  2022-04-07
* remove csv
* ignore csv

### 1.3.8 -  2022-04-06
* extend the documentation
* adjust documentation
* fix anchor
* added image
* added documentation for custom urls
* fix typo
* document token endpoint
* fix typo

### 1.3.7 -  2021-03-17
* adjust realm_url method

### 1.3.6 -  2020-06-12
* support multiple scopes with newer omniauth verisons

### 1.3.5 -  2019-09-19
* fix role loading from token

### 1.3.4 -  2019-05-02
* add more debug options
* added redirect back after login, so the url is not the root url in any case

### 1.3.3 -  2019-01-25
* change behaviour of handling aud and azp tokens

### 1.3.2 -  2018-12-07
* fix logout path for keycloak

### 1.3.1 -  2018-09-24
* make configurationb etter understandable

### 1.3.0 -  2018-09-18
* add routes.rb again
* update README.md
* corrected some mistakes in README.md
* update README.md
* update README.md
* Feature/user management (#2)

### 1.2.10 -  2018-07-27
* correct namespaces and add documentation to eager load problems

### 1.2.9 -  2018-07-27
* add route loader as emthod

### 1.2.8 -  2018-07-04
* try to load routes, and ignore laod failrues

### 1.2.7 -  2018-06-21
* make omniauth via rak robust

### 1.2.6 -  2018-06-21
* soem fixes for swagger integration via api_key

### 1.2.5 -  2018-05-15
* load routes in rails initilaizer

### 1.2.4 -  2018-03-26
* fix render for rails 5.1.5

### 1.2.3 -  2018-03-26
* fix api get_token aprams

### 1.2.2 -  2018-03-23
* remove typo

### 1.2.1 -  2018-03-23
* added rails 5 compatibility

### 1.2.0 -  2018-03-08
* Fix rack middleware (#1)
* add routes.rb again

### 1.1.3 -  2018-01-02
* remove explicite router require

### 1.1.2 -  2017-12-19
* allow only client usage for api clients

### 1.1.1 -  2017-09-26
* make usage of controller concern simpler and allow better overwrites

### 1.1.0 -  2017-09-05
* add rakc middleware to make oauth2 authentication
* Fix rack middleware (#1)

### 1.0.3 -  2017-03-15
* make the open-ID scope configurable

### 1.0.2 -  2017-01-25
* improove documentation and also logging on authorization failures

## 1.0.1
* remove not neccessary files after refactore

## 1.0.0
* correct isolate namespace
* better settigns management
* debug logging for role management
* fix redirect to main_app
* added basic testsuit
