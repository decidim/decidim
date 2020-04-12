# frozen_string_literal: true

module Capybara
  module CheckBoxSwitcher
    def switch_check_box(text)
      element = find_element(text)

      element.click unless hidden_child_input(element).checked?
    end

    def unswitch_check_box(text)
      element = find_element(text)

      element.click if hidden_child_input(element).checked?
    end

    private

    def hidden_child_input(element)
      within element do
        find("input[type='checkbox']", visible: false)
      end
    end

    def find_element(text)
      find("label", class: "switch-label", text: text)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::CheckBoxSwitcher, type: :system
end
