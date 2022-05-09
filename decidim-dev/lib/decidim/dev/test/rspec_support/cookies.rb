# frozen_string_literal: true

module Capybara
  module Cookies
    # Update cookie consent
    def select_cookies(cookies = "all", options = {})
      visit decidim.root_path if options[:visit_root]

      within ".footer" do
        click_link "Cookie settings"
      end

      if [true, "all"].include?(cookies)
        click_button "Accept all"
      elsif cookies.is_a?(Array)
        cookies.each do |cookie|
          within "[data-id='#{cookie}']" do
            find(".switch-paddle").click
          end
        end
        click_button "Save settings"
      elsif [false, "essential"].include?(cookies)
        click_button "Essential only"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Cookies, type: :system
end
