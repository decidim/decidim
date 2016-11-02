# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.3.1"

gemspec path: "."
gemspec path: "decidim-core"
gemspec path: "decidim-system"
gemspec path: "decidim-admin"
gemspec path: "decidim-dev"

gem "rubocop", "~> 0.45"
gem "rspec_junit_formatter", "0.2.3"
gem "simplecov", "~> 0.12"
gem "codecov", "~> 0.1.6"

eval(File.read(File.join(File.dirname(__FILE__), "Gemfile.common")))
