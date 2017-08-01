# frozen_string_literal: true

require "decidim/dev"

ENV["RAILS_ENV"] ||= "test"

root_path = File.expand_path("..", Dir.pwd)
engine_spec_dir = File.join(Dir.pwd, "spec")

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

require "#{Decidim::Dev.dummy_app_path}/config/environment"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{engine_spec_dir}/support/**/*.rb"].each { |f| require f }
Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require_relative "spec_helper"
