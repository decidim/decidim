# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"

if ENV["CI"]
  require "simplecov"
  SimpleCov.start

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

begin
  dummy_app_path = "#{ENV["ENGINE_NAME"]}_dummy_app/config/environment"
  require dummy_app_path
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake test_app`"
  puts "Tried to load it from #{dummy_app_path}"
  exit
end

require "rspec/rails"
require "factory_girl_rails"
require "database_cleaner"
require "byebug"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/rspec_support/**/*.rb"].each { |f| require f }
Dir["support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.fail_fast = ENV["FAIL_FAST"] || false
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include TranslationHelpers
end

require_relative "i18n_spec"
