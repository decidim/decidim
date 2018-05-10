# frozen_string_literal: true

SimpleCov.start do
  root File.expand_path("..", ENV["ENGINE_ROOT"])

  add_filter "decidim-dev/lib/decidim/dev/test/ext/screenshot_helper.rb"
  add_filter "/spec/decidim_dummy_app/"
  add_filter "/vendor/"
end

command_name = ENV["COMMAND_NAME"] || File.basename(Dir.pwd)
SimpleCov.command_name command_name + ENV.fetch("TEST_ENV_NUMBER", "")

SimpleCov.merge_timeout 1800
