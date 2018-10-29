# frozen_string_literal: true

# A collection of methods to enhance capybara methods attributes.
module CapybaraHelpers
  def double_click_link(link)
    2.times do
      click_link link
    end
  end
end
