# frozen_string_literal: true

require "decidim/dev"

ENV["RAILS_ENV"] ||= "test"

engine_spec_dir = File.join(Dir.pwd, "spec")

require "simplecov" if ENV["SIMPLECOV"]

require "decidim/core"
require "decidim/core/test"
require "decidim/admin/test"

require_relative "rspec_support/component.rb"
require_relative "rspec_support/authorization.rb"

require "#{Decidim::Dev.dummy_app_path}/config/environment"

Dir["#{engine_spec_dir}/shared/**/*.rb"].each { |f| require f }

require "paper_trail/frameworks/rspec"

require_relative "spec_helper"
