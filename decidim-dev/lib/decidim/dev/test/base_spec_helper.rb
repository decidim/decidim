# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"

engine_name = ENV["ENGINE_NAME"]
engine_spec_dir = File.join(Dir.pwd, "spec")
dummy_app_path = File.expand_path(File.join(engine_spec_dir, "#{engine_name}_dummy_app"))

if ENV["CI"]
  require "simplecov"
  SimpleCov.root(ENV["TRAVIS_BUILD_DIR"])

  SimpleCov.start do
    filters.clear
    add_filter "/test/"
    add_filter "/spec/"
    add_filter "bundle.js"
    add_filter "/vendor/"

    add_filter do |src|
      !(src.filename =~ /^#{ENV["TRAVIS_BUILD_DIR"]}/)
    end
  end

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "rails"
require "active_support/core_ext/string"
require "decidim/core"
require "decidim/core/test"

require "#{File.dirname(__FILE__)}/rspec_support/feature.rb"

begin
  require "#{dummy_app_path}/config/environment"
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake generate_test_app`"
  puts "Tried to load it from #{dummy_app_path}"
  exit(-1)
end

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
Dir["#{engine_spec_dir}/support/**/*.rb"].each { |f| require f }
Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

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

require_relative "i18n_spec"
