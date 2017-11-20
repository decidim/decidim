# frozen_string_literal: true

require "selenium-webdriver"
require "capybara-screenshot/rspec"

module Decidim
  # Helpers meant to be used only during capybara test runs.
  module CapybaraTestHelpers
    def switch_to_host(host = "lvh.me")
      unless /lvh\.me$/.match?(host)
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

Capybara.register_driver :headless_chrome do |app|
  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 90

  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless"
  options.args << "--no-sandbox"
  options.args << "--window-size=1024,768"

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
    http_client: http_client
  )
end

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.configure do |config|
  config.always_include_port = true
  config.default_driver = :headless_chrome
end

Capybara.asset_host = "http://localhost:3000"

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
