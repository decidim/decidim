# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "rails-controller-testing"
require "rspec/rails"
require "factory_bot_rails"
require "byebug"
require "cancan/matchers"
require "rectify/rspec"
require "wisper/rspec/stub_wisper_publisher"
require "db-query-matchers"
require 'action_view/helpers/sanitize_helper'

# Requires supporting files with custom matchers and macros, etc,
# in ./rspec_support/ and its subdirectories.
Dir["#{__dir__}/rspec_support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.fail_fast = ENV["FAIL_FAST"] == "true"
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec
  config.order = :random
  config.raise_errors_for_deprecations!

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include AttachmentHelpers
  config.include TranslationHelpers
  config.include Rectify::RSpec::Helpers
  config.include ActionView::Helpers::SanitizeHelper
end
