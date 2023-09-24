# frozen_string_literal: true

require "rails-controller-testing"
require "rspec/rails"
require "rspec/cells"
require "byebug"
require "wisper/rspec/stub_wisper_publisher"
require "action_view/helpers/sanitize_helper"
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
  config.filter_run_when_matching :focus
  config.profile_examples = 10
  config.default_formatter = "doc" if config.files_to_run.one?

  # If you are not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include ActionView::Helpers::SanitizeHelper
  config.include ERB::Util

  config.before :all, type: :system do
    ActiveStorage.service_urls_expire_in = 24.hours
  end

  config.before :all do
    Decidim.content_security_policies_extra = {
      "img-src": %w(https://via.placeholder.com)
    }
  end
end
