# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"

root_path = File.join(Dir.pwd, "..")
engine_name = ENV["ENGINE_NAME"]
engine_spec_dir = File.join(Dir.pwd, "spec")
dummy_app_path = File.expand_path(File.join(root_path, "spec", "decidim_dummy_app"))

if ENV["SIMPLECOV"]
  require "simplecov"
  SimpleCov.root(root_path)

  SimpleCov.start do
    filters.clear
    add_filter "/test/"
    add_filter "/spec/"
    add_filter "bundle.js"
    add_filter "/vendor/"

    add_filter do |src|
      !(src.filename =~ /^#{root_path}/)
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
