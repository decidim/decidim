# frozen_string_literal: true

require "decidim/dev"

ENV["RAILS_ENV"] ||= "test"

root_path = File.expand_path("..", Dir.pwd)
engine_spec_dir = File.join(Dir.pwd, "spec")

if ENV["SIMPLECOV"]
  require "simplecov"
  SimpleCov.root(root_path)

  SimpleCov.command_name File.basename(Dir.pwd)

  SimpleCov.start do
    filters.clear
    add_filter "/spec/decidim_dummy_app/"
    add_filter "bundle.js"
    add_filter "/vendor/"

    add_filter do |src|
      src.filename !~ /^#{root_path}/
    end
  end

  if ENV["CI"]
    require "codecov"
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
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
