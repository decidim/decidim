if ENV["CI"]
  require "simplecov"
  SimpleCov.start

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'decidim'
