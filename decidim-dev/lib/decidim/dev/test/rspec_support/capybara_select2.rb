# frozen_string_literal: true

# Adapted from https://github.com/goodwill/capybara-select2

module Capybara
  module Select2
    def select2(value, id:, search:)
      expect(page).to have_xpath("//select[@id='#{id}']/..")
      select2_container = find(:xpath, "//select[@id='#{id}']/..")

      expect(select2_container).to have_selector(".select2-selection")
      select2_container.find(".select2-selection").click

      if search
        body = find(:xpath, "//body")
        expect(body).to have_selector(".select2-search input.select2-search__field")
        body.find(".select2-search input.select2-search__field").set(value)

        page.execute_script(%|$("input.select2-search__field:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-dropdown"
      end

      expect(page).to have_no_content("Searching...")

      body = find(:xpath, "//body")
      expect(body).to have_selector("#{drop_container} li.select2-results__option", text: value)

      body.find("#{drop_container} li.select2-results__option", text: value).click
      expect(page).to have_select(id, with_options: [value])
    end
  end
end
