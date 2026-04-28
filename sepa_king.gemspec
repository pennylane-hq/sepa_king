lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sepa_king/version'

Gem::Specification.new do |s|
  s.name          = 'sepa_king'
  s.version       = SEPA::VERSION
  s.authors       = ['Georg Leciejewski', 'Georg Ledermann']
  s.email         = ['gl@salesking.eu', 'georg@ledermann.dev']
  s.description   = 'Implemention of Payments Initiation (ISO 20022)'
  s.summary       = 'Ruby gem for creating SEPA XML files'
  s.homepage      = 'https://github.com/salesking/sepa_king'
  s.license       = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 3.2.2'

  s.add_dependency 'activemodel', '>= 4.2'
  s.add_dependency 'iban-tools'
  s.add_dependency 'nokogiri'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'coveralls_reborn'
  s.add_development_dependency 'license_finder'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ruboclean'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'simplecov'
  s.metadata['rubygems_mfa_required'] = 'true'
end
