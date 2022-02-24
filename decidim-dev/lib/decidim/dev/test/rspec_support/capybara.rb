# frozen_string_literal: true

require "selenium-webdriver"
require "system_test_html_screenshots"

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

    def switch_to_secure_context_host
      Capybara.app_host = "http://localhost"
    end
  end
end

# Customize the screenshot helper to fix the file paths for examples that have
# unallowed characters in them. Otherwise the artefacts creation and upload
# fails at GitHub actions. See the list of unallowed characters from:
# https://github.com/actions/toolkit/blob/main/packages/artifact/docs/additional-information.md#non-supported-characters
module ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
  # This method is not needed after update to Rails 7.0
  def _screenshot_counter
    @_screenshot_counter ||= 0
    @_screenshot_counter += 1
  end

  def image_name
    # By default, this only cleans up the forward and backward slash characters.
    sanitized_method_name = method_name.tr("/\\()\":<>|*?", "-----------")
    # The unique method is automatically available after update to Rails 7.0,
    # so the following line can be removed after upgrade to Rails 7.0.
    unique = failed? ? "failures" : (_screenshot_counter || 0).to_s
    name = "#{unique}_#{sanitized_method_name}"
    name[0...225]
  end
end

Capybara.register_driver :headless_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless"
  options.args << "--no-sandbox"
  options.args << if ENV["BIG_SCREEN_SIZE"].present?
                    "--window-size=1920,3000"
                  else
                    "--window-size=1920,1080"
                  end

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.register_driver :iphone do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless"
  options.args << "--no-sandbox"
  options.add_emulation(device_name: "iPhone 6")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.server = :puma, { Silent: true, Threads: "1:1" }

Capybara.asset_host = "http://localhost:3000"

Capybara.server_errors = [SyntaxError, StandardError]

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before :each, type: :system do
    driven_by(:headless_chrome)
    switch_to_default_host
  end

  config.before :each, driver: :rack_test do
    driven_by(:rack_test)
  end

  config.around :each, :slow do |example|
    max_wait_time_for_slow_specs = 30

    using_wait_time(max_wait_time_for_slow_specs) do
      example.run
    end
  end

  config.after(type: :system) do |example|
    warn page.driver.browser.manage.logs.get(:browser) unless example.metadata[:driver].eql?(:rack_test)
  end

  config.include Decidim::CapybaraTestHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :system
end
