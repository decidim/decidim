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

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{engine_spec_dir}/support/**/*.rb"].each { |f| require f }
Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require_relative "spec_helper"
require_relative "i18n_spec"
