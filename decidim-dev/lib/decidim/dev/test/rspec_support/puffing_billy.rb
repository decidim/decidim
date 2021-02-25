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

# A patch to `puffing-billy`'s proxy so that it doesn't try to stop
# eventmachine's reactor if it's not running.
#
# See:
# https://github.com/oesmith/puffing-billy/issues/253#issuecomment-539710620
module BillyProxyPatch
  def stop
    return unless EM.reactor_running?

    super
  end
end
Billy::Proxy.prepend(BillyProxyPatch)

# A patch to `puffing-billy` to start EM if it has been stopped
Billy.module_eval do
  def self.proxy
    if @billy_proxy.nil? || !(EventMachine.reactor_running? && EventMachine.reactor_thread.alive?)
      proxy = Billy::Proxy.new
      proxy.start
      @billy_proxy = proxy
    else
      @billy_proxy
    end
  end
end
