ENV['RAILS_ENV'] ||= 'test'
# Prevent database truncation if the environment is production
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'shoulda/matchers'
require 'database_cleaner'
require 'capybara/rails'

ActiveRecord::Migration.maintain_test_schema!
Capybara.match = :prefer_exact

RSpec.configure do |config|
  # config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
    Warden.test_mode!
  end

  config.around(:each) do |spec|
    DatabaseCleaner.cleaning do
      spec.run
    end
  end
end
