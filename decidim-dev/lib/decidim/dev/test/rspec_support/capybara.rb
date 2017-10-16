# frozen_string_literal: true

require "capybara/poltergeist"
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

capybara_options = {
  extensions: [
    File.join(__dir__, "phantomjs_polyfills", "promise.js"),
    File.join(__dir__, "phantomjs_polyfills", "phantomjs-shim.js"),
    File.join(__dir__, "phantomjs_polyfills", "phantomjs-getOwnPropertyNames.js"),
    File.join(__dir__, "phantomjs_polyfills", "weakmap-polyfill.js")
  ],
  js_errors: true,
  url_whitelist: ["http://*.lvh.me", "localhost", "127.0.0.1"],
  timeout: 2.minutes
}

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, capybara_options)
end

Capybara.register_driver :debug do |app|
  Capybara::Poltergeist::Driver.new(app, capybara_options.merge(inspector: true))
end

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot::RSpec.add_link_to_screenshot_for_failed_examples = true

Capybara.configure do |config|
  config.always_include_port = true
  config.default_driver = :poltergeist
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
