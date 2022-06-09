# frozen_string_literal: true

require "rails-controller-testing"
require "rspec/rails"
require "rspec/cells"
require "byebug"
require "wisper/rspec/stub_wisper_publisher"
require "db-query-matchers"
require "action_view/helpers/sanitize_helper"
require "axe-rspec"
require "w3c_rspec_validators"
require "decidim/dev/test/w3c_rspec_validators_overrides"

# Requires supporting files with custom matchers and macros, etc,
# in ./rspec_support/ and its subdirectories.
Dir["#{__dir__}/rspec_support/**/*.rb"].each { |f| require f }

require_relative "factories"

RSpec.configure do |config|
  config.color = true
  config.fail_fast = ENV.fetch("FAIL_FAST", nil) == "true"
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.order = :random
  config.raise_errors_for_deprecations!
  config.example_status_persistence_file_path = ".rspec-failures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include ActionView::Helpers::SanitizeHelper
  config.include ERB::Util
end
