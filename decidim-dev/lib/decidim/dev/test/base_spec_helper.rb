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
require_relative "rspec_support/authorization.rb"

require "#{Decidim::Dev.dummy_app_path}/config/environment"

Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require_relative "spec_helper"
