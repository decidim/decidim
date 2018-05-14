# frozen_string_literal: true

SimpleCov.start do
  root File.expand_path("..", ENV["ENGINE_ROOT"])

  add_filter "decidim-dev/lib/decidim/dev/test/ext/screenshot_helper.rb"
  add_filter "/spec/decidim_dummy_app/"
  add_filter "/vendor/"
end

SimpleCov.command_name ENV["COMMAND_NAME"] || File.basename(Dir.pwd)

SimpleCov.merge_timeout 1800
