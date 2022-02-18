# frozen_string_literal: true

module Capybara
  module AutoCompleteJS
    def autocomplete_select(value, from:)
      within("div[data-autocomplete-for='#{from}']") do
        find(".autocomplete-input").click
        find(".autocomplete-input").native.send_keys(value[0..4])
        expect(page).to have_css("#autoComplete_list_1") # select should be open now

        expect(page).to have_css("#autoComplete_result_0", text: value)
        find("#autoComplete_result_0", text: value).hover
        expect(page).to have_css("#autoComplete_result_0", text: value)
        find("#autoComplete_result_0", text: value).click
        expect(page).to have_css(".autocomplete__selected-item", text: value)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::AutoCompleteJS, type: :system
end
