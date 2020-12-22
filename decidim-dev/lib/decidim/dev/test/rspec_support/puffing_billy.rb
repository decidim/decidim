# frozen_string_literal: true

require "billy/capybara/rspec"

Billy.configure do |config|
  config.cache = true
  config.persist_cache = true
  config.cache_path = "spec/billy"
  config.record_requests = true
  config.proxied_request_connect_timeout = 20
  config.proxied_request_inactivity_timeout = 20
end

RSpec.configure do |config|
  config.before :each, :billy do
    driven_by :selenium_chrome_headless_billy
    switch_to_default_host
    WebMock::HttpLibAdapters::EmHttpRequestAdapter.disable!
  end
end
