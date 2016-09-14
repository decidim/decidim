# frozen_string_literal: true
if ENV["CI"]
  require "simplecov"
  SimpleCov.start

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov

  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "decidim"
