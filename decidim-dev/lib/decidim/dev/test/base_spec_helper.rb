# frozen_string_literal: true

require "decidim/dev"

ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_SYSTEM_TESTING_SCREENSHOT_HTML"] ||= "1"
ENV["DECIDIM_API_JWT_SECRET"] ||= "dummy-api-jwt-secret"
ENV["DECIDIM_AVAILABLE_LOCALES"] ||= "en,ca,es"
ENV["DECIDIM_ENABLE_MACHINE_TRANSLATION"] ||= "true"
ENV["DECIDIM_SPAM_DETECTION_BACKEND_RESOURCE"] ||= "memory"
ENV["DECIDIM_SPAM_DETECTION_BACKEND_USER"] ||= "memory"
ENV["DECIDIM_SMS_GATEWAY_SERVICE"] ||= "Decidim::Verifications::Sms::ExampleGateway"
ENV["DECIDIM_TIMESTAMP_SERVICE"] ||= "Decidim::Initiatives::DummyTimestamp"
ENV["DECIDIM_PDF_SIGNATURE_SERVICE"] ||= "Decidim::PdfSignatureExample"

engine_spec_dir = File.join(Dir.pwd, "spec")

require "simplecov" if ENV["SIMPLECOV"]

require "decidim/core"
require "decidim/dev/component"
require "decidim/core/test"
require "decidim/admin/test"
require "decidim/api/test"

require_relative "rspec_support/component"
require_relative "rspec_support/authorization"

require "#{Decidim::Dev.dummy_app_path}/config/environment"

Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require "paper_trail/frameworks/rspec"

require_relative "spec_helper"

if ENV["CI"]
  require "rspec/retry"

  RSpec.configure do |config|
    # show retry status in spec process
    config.verbose_retry = true
    # show exception that triggers a retry if verbose_retry is set to true
    config.display_try_failure_messages = true

    # Retry failed test, set to 1 for normal behavior
    config.default_retry_count = ENV.fetch("FAILED_TEST_RETRY_COUNT", 3)
  end
end
