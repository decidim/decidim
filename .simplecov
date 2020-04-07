# frozen_string_literal: true

SimpleCov.start do
  root File.expand_path("..", ENV["ENGINE_ROOT"])

  add_filter "decidim-dev/lib/decidim/dev/test/ext/screenshot_helper.rb"
  add_filter "/config/"
  add_filter "/migrate/"
  add_filter "/spec/decidim_dummy_app/"
  add_filter "/vendor/"
  add_filter "/spec/"
  add_filter "/test/"
end

SimpleCov.merge_timeout 1800

if ENV["CI"]
  require "simplecov-cobertura"
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end
