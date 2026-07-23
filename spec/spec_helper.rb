require 'operto'
require 'vcr'
require 'webmock/rspec'
require 'active_support/testing/time_helpers'

require_relative 'support/test_token_store'

Time.zone = 'UTC'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('fixtures/cassettes', __dir__)
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.disable_monkey_patching!
  config.include ActiveSupport::Testing::TimeHelpers

  config.before do
    Operto.configure do |operto|
      operto.client_id = 'test-client-id'
      operto.secret = 'test-secret'
      operto.token_store = TestTokenStore.with_active_token
    end
  end
end
