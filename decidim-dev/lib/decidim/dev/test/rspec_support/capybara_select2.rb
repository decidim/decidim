# frozen_string_literal: true

# extracted from https://github.com/goodwill/capybara-select2

module Capybara
  module Select2
    def select2(value, xpath:, search:)
      expect(page).to have_xpath(xpath)
      select2_container = find(:xpath, xpath)

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
    end
  end
end
