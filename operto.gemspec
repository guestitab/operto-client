require_relative 'lib/operto/version'

Gem::Specification.new do |spec|
  spec.name        = 'operto'
  spec.version     = Operto::VERSION
  spec.authors     = ['Guestit']
  spec.summary     = 'Client for the Operto Teams API'
  spec.description = 'HTTP client and operations for the Operto Teams API, decoupled from the host application.'
  spec.required_ruby_version = '>= 4.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'dry-monads'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday-retry'
  spec.add_dependency 'oj'
end
