# frozen_string_literal: true

require "selenium-webdriver"

module Decidim
  # Helpers meant to be used only during capybara test runs.
  module CapybaraTestHelpers
    def switch_to_host(host = "lvh.me")
      raise "Can't switch to a custom host unless it really exists. Use `whatever.lvh.me` as a workaround." unless /lvh\.me$/.match?(host)

      app_host = (host ? "#{protocol}://#{host}" : nil)
      Capybara.app_host = app_host
    end

    def switch_to_default_host
      Capybara.app_host = nil
    end

    def switch_to_secure_context_host
      Capybara.app_host = "#{protocol}://localhost"
    end

    def protocol
      return "https" if ENV["TEST_SSL"]

      "http"
    end
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
  options.args << "--ignore-certificate-errors" if ENV["TEST_SSL"]
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: [options]
  )
end

Capybara.server_port = rand(5000..6999)

# In order to work with PWA apps, Chrome can't be run in headless mode, and requires
# setting up special prefs and flags
Capybara.register_driver :pwa_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  options.args << "--no-sandbox"
  # Don't limit browser resources
  options.args << "--disable-dev-shm-usage"
  # Add pwa.lvh.me host as a secure origin
  options.args << "--unsafely-treat-insecure-origin-as-secure=http://pwa.lvh.me:#{Capybara.server_port}"
  # User data flag is mandatory when preferences and locale state is set
  options.args << "--user-data-dir=/tmp/decidim_tests_user_data_#{rand(1000)}"
  options.args << if ENV["BIG_SCREEN_SIZE"].present?
                    "--window-size=1920,3000"
                  else
                    "--window-size=1920,1080"
                  end
  # Set notifications allowed in http protocol
  options.local_state["browser.enabled_labs_experiments"] = ["enable-system-notifications@1", "unsafely-treat-insecure-origin-as-secure"]
  # Mark notification permission as enabled
  options.prefs["profile.default_content_setting_values.notifications"] = 1

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    capabilities: [options]
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
    capabilities: [options]
  )
end

server_options = { Silent: true, queue_requests: false }
if ENV["TEST_SSL"]
  dev_gem = Bundler.load.specs.find { |spec| spec.name == "decidim-dev" }
  cert_dir = "#{dev_gem.full_gem_path}/lib/decidim/dev/assets"
  server_options.merge!(
    Host: "ssl://#{Capybara.server_host}:#{Capybara.server_port}?key=#{cert_dir}/ssl-key.pem&cert=#{cert_dir}/ssl-cert.pem"
  )
  Capybara.asset_host = "https://localhost:3000"
else
  Capybara.asset_host = "http://localhost:3000"
end
Capybara.server = :puma, server_options

Capybara.server_errors = [SyntaxError, StandardError]

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before :each, type: :system do
    driven_by(:headless_chrome)
    switch_to_default_host
    domain = (try(:organization) || try(:current_organization))&.host
    if domain
      # Javascript sets the cookie also for all subdomains but localhost is a
      # special case.
      domain = ".#{domain}" unless domain == "localhost"
      page.driver.browser.execute_cdp(
        "Network.setCookie",
        domain: domain,
        name: Decidim.consent_cookie_name,
        value: { essential: true }.to_json,
        path: "/",
        expires: 1.day.from_now.to_i,
        same_site: "Lax"
      )
    end
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
    warn page.driver.browser.logs.get(:browser) unless example.metadata[:driver].eql?(:rack_test)
  end

  config.include Decidim::CapybaraTestHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :system
end
