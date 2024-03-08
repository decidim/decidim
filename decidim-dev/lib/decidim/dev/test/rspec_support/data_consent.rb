# frozen_string_literal: true

module Capybara
  module DataConsent
    # Update data consent
    def data_consent(categories = "all", options = {})
      visit decidim.root_path if options[:visit_root]

      dialog_present = begin
        find_by_id("dc-dialog-wrapper")
      rescue Capybara::ElementNotFound => _e
        false
      end

      if dialog_present
        click_on "Settings"
      else
        within "footer" do
          click_on "Cookie settings"
        end
      end

      if [true, "all"].include?(categories)
        click_on "Accept all"
      elsif categories.is_a?(Array)
        categories.each do |category|
          within "[data-id='#{category}']" do
            find(".cookies__category-toggle").click
          end
        end
        click_on "Save settings"
      elsif [false, "essential"].include?(categories)
        click_on "Accept only essential"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::DataConsent, type: :system
end
