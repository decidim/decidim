# frozen_string_literal: true

require "selenium-webdriver"

module Decidim
  # Helpers meant to be used only during capybara test runs.
  module CapybaraTestHelpers
    def switch_to_host(host = "lvh.me")
      raise "Cannot switch to a custom host unless it really exists. Use `whatever.lvh.me` as a workaround." unless /lvh\.me$/.match?(host)

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

1.step do
  port = rand(5000..6999)
  begin
    Socket.tcp("127.0.0.1", port, connect_timeout: 5).close
    warn "Port #{port} is already in use, trying another one."
  rescue Errno::ECONNREFUSED
    # When connection is refused, the port is available for use.
    Capybara.server_port = port
    break
  end
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << "--explicitly-allowed-ports=#{Capybara.server_port}"
  options.args << "--headless=new"
  options.args << "--disable-search-engine-choice-screen" # Prevents closing the window normally
  # Do not limit browser resources
  options.args << "--disable-dev-shm-usage"
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
    options:
  )
end

# In order to work with PWA apps, Chrome cannot be run in headless mode, and requires
# setting up special prefs and flags
Capybara.register_driver :pwa_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << "--explicitly-allowed-ports=#{Capybara.server_port}"
  # If we have a headless browser things like the offline navigation feature stop working,
  # so we need to have have a headful/recapitated (aka not headless) browser for these specs
  # options.args << "--headless"
  options.args << "--no-sandbox"
  # Do not limit browser resources
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
    options:
  )
end

Capybara.register_driver :iphone do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.args << "--headless=new"
  options.args << "--no-sandbox"
  # Do not limit browser resources
  options.args << "--disable-dev-shm-usage"
  options.add_emulation(device_name: "iPhone 6")

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options:
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
Capybara.save_path = Rails.root.join("tmp/screenshots")

Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before :all, type: :system do
    if ENV["BIG_SCREEN_SIZE"].present?
      warn "[DECIDIM] ChromeDriver Workaround is being active: Setting window size to 1920x3000."
    else
      warn "[DECIDIM] ChromeDriver Workaround is being active: Setting window size to 1920x1080."
    end
  end

  config.before :each, type: :system do
    driven_by(:headless_chrome)

    # Workaround for flaky spec related to resolution change
    #
    # For some unknown reason, depending on the order run for these specs, the resolution is changed to
    # 800x600, which breaks the drag and drop. This forces the resolution to be 1920x1080.
    # One possible culprit for the screen resolution change is the alert error intercepting which messes with the window focus.
    # This has been reported to SeleniumHQ, https://github.com/SeleniumHQ/selenium/issues/13553
    # and to the chromedriver project, https://bugs.chromium.org/p/chromedriver/issues/detail?id=4709
    #
    # Note to future maintainers: If you remove this workaround, please make sure to check if the issue has been fixed.
    # If that is the case, please remove this comment, workaround, and the above warning that starts with "[DECIDIM] ChromeDriver Workaround".
    if ENV["BIG_SCREEN_SIZE"].present?
      current_window.resize_to(1920, 3000)
    else
      current_window.resize_to(1920, 1080)
    end

    switch_to_default_host
    domain = (try(:organization) || try(:current_organization))&.host
    if domain
      # Javascript sets the cookie also for all subdomains but localhost is a
      # special case.
      domain = ".#{domain}" unless domain == "localhost"
      page.driver.browser.execute_cdp(
        "Network.setCookie",
        domain:,
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
