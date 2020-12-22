# frozen_string_literal: true

require "billy/capybara/rspec"

Billy.configure do |config|
  config.cache = true
  config.persist_cache = true
  config.cache_path = "spec/billy"
  config.record_requests = true
  config.proxied_request_connect_timeout = 20
  config.proxied_request_inactivity_timeout = 20
  config.merge_cached_responses_whitelist = [%r{/api$}]
end

RSpec.configure do |config|
  base_cache_path = Billy.config.cache_path

  config.before :each, :billy do |example|
    driven_by :selenium_chrome_headless_billy
    switch_to_secure_context_host
    WebMock::HttpLibAdapters::EmHttpRequestAdapter.disable!

    feature_name = example.metadata[:example_group][:description].underscore.gsub(" ", "_")
    scenario_name = example.metadata[:description].underscore.gsub(" ", "_")
    cache_scenario_folder_path = File.join(base_cache_path, feature_name, scenario_name)
    FileUtils.mkdir_p(cache_scenario_folder_path)
    Billy.config.cache_path = cache_scenario_folder_path
  end
end
