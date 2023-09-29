# frozen_string_literal: true

module Capybara
  module DatepickerTimeFill
    # fill datepicker field correctly

    def fill_in_timepicker(locator = nil, with:, currently_with: nil, fill_options: {}, **find_options)
      find_options[:with] = currently_with if currently_with
      find_options[:allow_self] = true if locator.nil?
      with.chars.each do |character|
        if character == ":"
          find(:fillable_field, locator, **find_options).send_keys([:alt, ":"], **fill_options)
        else
          find(:fillable_field, locator, **find_options).send_keys(character, **fill_options)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::DatepickerTimeFill, type: :system
end
