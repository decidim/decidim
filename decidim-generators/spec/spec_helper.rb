# frozen_string_literal: true

require "decidim/generators"

require "json"
require "fileutils"
require "decidim/gem_manager"

ENV["RETRY_TIMES"] = "0"

if ENV["SIMPLECOV"]
  require "simplecov"

  SimpleCov.add_filter "/lib/decidim/generators/app_templates/"
  SimpleCov.add_filter "/lib/decidim/generators/component_templates/"
end

RSpec.configure do |config|
  config.fail_fast = ENV.fetch("FAIL_FAST", nil) == "true"
end
