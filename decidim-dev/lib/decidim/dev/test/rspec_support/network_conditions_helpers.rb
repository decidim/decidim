# frozen_string_literal: true

module NetworkConditionsHelpers
  def with_browser_in_offline_mode
    page.driver.browser.network_conditions = { offline: true }

    # Wait for the browser to be offline
    sleep 1

    yield

    page.driver.browser.network_conditions = { offline: false }
  end
end

RSpec.configure do |config|
  config.include NetworkConditionsHelpers, type: :system
end
