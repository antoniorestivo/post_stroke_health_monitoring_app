ENV['RAILS_ENV'] = 'test'
ENV['RACK_ENV']  = 'test'

require_relative 'support/auth_helpers'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.warnings = false
  config.include AuthHelpers, type: :request

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
