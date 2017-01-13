# frozen_string_literal: true
if ENV["CI"]
  require "simplecov"
  SimpleCov.root(ENV["TRAVIS_BUILD_DIR"])

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
