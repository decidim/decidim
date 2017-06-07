# frozen_string_literal: true

# Helpers to overcome bugs with headless chrome
module Decidim::ChromeWorkarounds
  # This is a workaround for headless chrome not being able to accept alert
  # dialogs. Once this is fixed upstream. The method should be removed so that
  # tests automatically use capybara's `accept_alert`.
  def accept_alert
    evaluate_script("window.confirm = function() { return true; }")
    yield
  end
end

RSpec.configure do |config|
  config.include Decidim::ChromeWorkarounds, type: :feature
end
