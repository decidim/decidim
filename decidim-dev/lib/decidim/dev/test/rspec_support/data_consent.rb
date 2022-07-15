# frozen_string_literal: true

module Capybara
  module DataConsent
    # Update data consent
    def data_consent(categories = "all", options = {})
      visit decidim.root_path if options[:visit_root]

      dialog_present = begin
        find("#dc-dialog-wrapper")
      rescue Capybara::ElementNotFound => _e
        false
      end

      if dialog_present
        click_button "Settings"
      else
        within ".footer" do
          click_link "Cookie settings"
        end
      end

      if [true, "all"].include?(categories)
        click_button "Accept all"
      elsif categories.is_a?(Array)
        categories.each do |category|
          within "[data-id='#{category}']" do
            find(".switch-paddle").click
          end
        end
        click_button "Save settings"
      elsif [false, "essential"].include?(categories)
        click_button "Accept only essential"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::DataConsent, type: :system
end
