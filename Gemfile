# frozen_string_literal: true
eval(File.read(File.dirname(__FILE__) + "/common_gemfile.rb"))

# Specify your gem's dependencies in decidim.gemspec
gemspec
gem "rspec_junit_formatter", "0.2.3", group: :test, require: false
gem "codecov", require: false, group: :test

gemspec path: "."
gemspec path: "decidim-core"

gem "rubocop"
