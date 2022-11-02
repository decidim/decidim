# frozen_string_literal: true

module FrontendHelpers
  # Thanks to:
  # https://medium.com/@coorasse/catch-javascript-errors-in-your-system-tests-89c2fe6773b1
  def expect_no_js_errors
    errors = page.driver.browser.logs.get(:browser)
    return if errors.blank?

    aggregate_failures "javascript errors" do
      errors.each do |error|
        expect(error.level).not_to eq("SEVERE"), error.message
      end
    end
  end

  # Thanks to:
  # https://thoughtbot.com/blog/automatically-wait-for-ajax-with-capybara
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script("jQuery.active").zero?
  end
end

RSpec.configure do |config|
  config.include FrontendHelpers, type: :system
end
