# frozen_string_literal: true

require "selenium-webdriver"
require "capybara-screenshot/rspec"

module Decidim
  # Helpers meant to be used only during capybara test runs.
  module CapybaraTestHelpers
    def switch_to_host(host = "lvh.me")
      raise "Can't switch to a custom host unless it really exists. Use `whatever.lvh.me` as a workaround." unless /lvh\.me$/.match?(host)

      app_host = (host ? "http://#{host}" : nil)
      Capybara.app_host = app_host
    end

    def switch_to_default_host
      Capybara.app_host = nil
    end
  end
end

Capybara.register_driver :headless_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless"
  options.args << "--no-sandbox"
  options.args << "--window-size=1024,768"

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.server = :puma, { Silent: true }

Capybara.asset_host = "http://localhost:3000"

Capybara.server_errors = [SyntaxError, StandardError]

Capybara.save_path = "/tmp/screenshots"

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true

Capybara::Screenshot.register_driver(:headless_chrome) do |driver, path|
  driver.browser.save_screenshot(path)
end

RSpec.configure do |config|
  config.before :each, type: :system do
    driven_by(:headless_chrome)
    switch_to_default_host
  end

  config.after :each, type: :system do |example|
    Capybara::Screenshot::RSpec.after_failed_example(example)
  end

  config.before :each, driver: :rack_test do
    driven_by(:rack_test)
  end

  config.around :each, :slow do |example|
    max_wait_time_for_slow_specs = 7

    using_wait_time(max_wait_time_for_slow_specs) do
      example.run
    end
  end

  config.include Decidim::CapybaraTestHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :system
end
