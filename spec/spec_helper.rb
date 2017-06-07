# frozen_string_literal: true

if ENV["SIMPLECOV"]
  require "simplecov"
  SimpleCov.start

  if ENV["CI"]
    require "codecov"
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "decidim"
