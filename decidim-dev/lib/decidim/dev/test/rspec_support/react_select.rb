# frozen_string_literal: true

# Adapted from https://github.com/JedWatson/react-select/issues/832#issuecomment-276441836

module Capybara
  module ReactSelect
    def autocomplete_select(value, from:)
      within("div[data-autocomplete-for='#{from}']") do
        find(".Select-control").click

        find(".Select .Select-input input").native.send_keys(value[0..4])
        expect(page).to have_css(".Select-menu-outer") # select should be open now

        # This is a little funky because when the entered text forces the select to
        # wrap, it causes React to re-render.  We need to get it to re-render
        # (if needed) by hovering.
        expect(page).to have_css(".Select-option", text: value)
        find(".Select-option", text: value).hover
        expect(page).to have_css(".Select-option", text: value)
        find(".Select-option", text: value).click
        expect(page).to have_css(".Select-value-label", text: value)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::ReactSelect, type: :system
end
