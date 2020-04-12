# frozen_string_literal: true

module Capybara
  module Switcher
    def switch(text)
      element = find_element(text)

      element.click unless hidden_sibling_input(element).checked?
    end

    def unswitch(text)
      element = find_element(text)

      element.click if hidden_sibling_input(element).checked?
    end

    private

    def hidden_sibling_input(element)
      element.sibling("input[type='checkbox']", visible: false)
    end

    def find_element(text)
      find("span", class: "switch-label", text: text)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Switcher, type: :system
end
