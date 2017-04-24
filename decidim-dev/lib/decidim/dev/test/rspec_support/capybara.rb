# frozen_string_literal: true

require "capybara-screenshot/rspec"
require 'selenium-webdriver'

module Decidim
  # Helpers meant to be used only during capybara test runs.
  module CapybaraTestHelpers
    def switch_to_host(host = "lvh.me")
      unless /lvh\.me$/ =~ host
        raise "Can't switch to a custom host unless it really exists. Use `whatever.lvh.me` as a workaround."
      end

      app_host = (host ? "http://#{host}" : nil)
      Capybara.app_host = app_host
    end

    def switch_to_default_host
      Capybara.app_host = nil
    end
  end
end

Capybara.register_driver :chromium do |app|
  if ENV['CAPYBARA_CHROMIUM_BIN'].present?
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      "chromeOptions" => {
        'binary' => ENV['CAPYBARA_CHROMIUM_BIN'],
        'args' => ['headless', 'disable-gpu']
      }
    )
  else
    caps = Selenium::WebDriver::Remote::Capabilities.chrome
  end
  driver = Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: caps
  )
end

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true

Capybara.configure do |config|
  config.always_include_port = true
  config.default_driver = :chromium
  config.always_include_port = true
end

RSpec.configure do |config|
  config.before :each, type: :feature do
    Capybara.current_session.driver.reset!
    switch_to_default_host
  end

  config.include Decidim::CapybaraTestHelpers, type: :feature

  if ENV["CI"]
    require "rspec/repeat"

    config.include RSpec::Repeat
    config.around :each, type: :feature do |example|
      repeat example, 5.times, wait: 1, verbose: true
    end
  end
end
