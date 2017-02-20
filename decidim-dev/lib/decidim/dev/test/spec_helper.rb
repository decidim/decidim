# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"

require "rails"
require "active_support/core_ext/string"
require "decidim/core"
require "decidim/core/test"

require "rails-controller-testing"
require "rspec/rails"
require "factory_girl_rails"
require "database_cleaner"
require "byebug"
require "cancan/matchers"
require "rectify/rspec"
require "wisper/rspec/stub_wisper_publisher"
require "db-query-matchers"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/rspec_support/**/*.rb"].each { |f| require f }

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
  config.include Rectify::RSpec::Helpers
end
