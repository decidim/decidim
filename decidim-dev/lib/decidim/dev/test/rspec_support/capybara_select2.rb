# frozen_string_literal: true

module Capybara
  module Select2
    def select2(value, from:)
      expect(page).to have_xpath("//select[@id='#{from}']/..")
      select2_container = find(:xpath, "//select[@id='#{from}']/..")

      expect(select2_container).to have_selector(".select2-selection")
      select2_container.find(".select2-selection").click

      body = find(:xpath, "//body")
      expect(body).to have_selector(".select2-dropdown li.select2-results__option", text: value)

      body.find(".select2-dropdown li.select2-results__option", text: value).click
      expect(page).to have_select(from, with_options: [value])
    end
  end
end
