# frozen_string_literal: true

require "decidim/dev"

ENV["RAILS_ENV"] ||= "test"

root_path = File.expand_path("..", Dir.pwd)
engine_spec_dir = File.join(Dir.pwd, "spec")

if ENV["SIMPLECOV"]
  require "simplecov/no_defaults"

  SimpleCov.root(root_path)
  require "simplecov/defaults"

  SimpleCov.command_name File.basename(Dir.pwd)
end

require "rails"
require "active_support/core_ext/string"
require "decidim/core"
require "decidim/core/test"

require_relative "rspec_support/feature.rb"

begin
  require "#{Decidim::Dev.dummy_app_path}/config/environment"
rescue LoadError
  puts "Could not load dummy application. Please ensure you have run `bundle exec rake decidim:generate_test_app`"
  puts "Tried to load it from #{Decidim::Dev.dummy_app_path}"
  exit(-1)
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{engine_spec_dir}/support/**/*.rb"].each { |f| require f }
Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require_relative "spec_helper"
