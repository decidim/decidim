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
end

RSpec.configure do |config|
  config.include FrontendHelpers, type: :system
end
