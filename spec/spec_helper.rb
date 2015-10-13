def zeus_running?
  File.exists? '.zeus.sock'
end

if zeus_running?
  require 'simplecov'
  SimpleCov.start 'rails'
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  Kernel.srand config.seed
end
