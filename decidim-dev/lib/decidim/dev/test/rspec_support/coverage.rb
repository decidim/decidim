# frozen_string_literal: true
if ENV["CI"]
  require "simplecov"
  SimpleCov.root(ENV["TRAVIS_BUILD_DIR"])

  SimpleCov.start do
    filters.clear
    add_filter "/test/"
    add_filter "/spec/"
    add_filter "/vendor/"
    add_filter "/.bundle/"

    add_filter do |src|
      !(src.filename =~ /^#{ENV["TRAVIS_BUILD_DIR"]}/)
    end
  end

  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
