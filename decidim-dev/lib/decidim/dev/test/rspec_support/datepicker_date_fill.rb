# frozen_string_literal: true

module Capybara
  module DatepickerDateFill
    # fill datepicker field correctly

    def fill_in_datepicker(locator = nil, with:, currently_with: nil, fill_options: {}, **find_options)
      find_options[:with] = currently_with if currently_with
      find_options[:allow_self] = true if locator.nil?
      with.chars.each do |character|
        if character == "/"
          find(:fillable_field, locator, **find_options).send_keys(:divide, **fill_options)
        elsif character == "."
          find(:fillable_field, locator, **find_options).send_keys(:decimal, **fill_options)
        else
          find(:fillable_field, locator, **find_options).send_keys(character, **fill_options)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::DatepickerDateFill, type: :system
end
