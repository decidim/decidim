# frozen_string_literal: true

# extracted from https://github.com/goodwill/capybara-select2

module Capybara
  module Select2
    def select2(value, options = {})
      raise "Must pass a hash containing 'from' or 'xpath' or 'css'" unless options.is_a?(Hash) && [:from, :xpath, :css].any? { |k| options.has_key? k }

      if options.has_key? :xpath
        select2_container = find(:xpath, options[:xpath])
      elsif options.has_key? :css
        select2_container = find(:css, options[:css])
      else
        select_name = options[:from]
        select2_container = find("label", text: select_name).find(:xpath, "..").find(".select2-container")
      end

      # Open select2 field
      select2_container.find(".select2-selection").click

      if options.has_key? :search
        find(:xpath, "//body").find(".select2-search input.select2-search__field").set(value)
        page.execute_script(%|$("input.select2-search__field:visible").keyup();|)
        drop_container = ".select2-results"
      else
        drop_container = ".select2-dropdown"
      end

      expect(page).to have_no_content("Searching...")

      [value].flatten.each do |val|
        find(:xpath, "//body").find("#{drop_container} li.select2-results__option", text: val).click
      end
    end
  end
end
