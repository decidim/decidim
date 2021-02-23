# frozen_string_literal: true

require "decidim/dev/test/rspec_support/capybara_data_picker"

module Capybara
  module PollingOfficersPicker
    include DataPicker

    RSpec::Matchers.define :have_polling_officers_picked do |expected|
      match do |polling_officers_picker|
        data_picker = polling_officers_picker.data_picker

        expected.each do |polling_officer|
          expect(data_picker).to have_selector(".picker-values div input[value='#{polling_officer.id}']", visible: :all)
          expect(data_picker).to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,\"#{translated(polling_officer.name)}\")]]")
        end
      end
    end

    RSpec::Matchers.define :have_polling_officers_not_picked do |expected|
      match do |polling_officers_picker|
        data_picker = polling_officers_picker.data_picker

        expected.each do |polling_officer|
          expect(data_picker).not_to have_selector(".picker-values div input[value='#{polling_officer.id}']", visible: :all)
          expect(data_picker).not_to have_selector(:xpath, "//div[contains(@class,'picker-values')]/div/a[text()[contains(.,\"#{translated(polling_officer.name)}\")]]")
        end
      end
    end

    def polling_officers_pick(polling_officers_picker, polling_officers)
      data_picker = polling_officers_picker.data_picker

      expect(data_picker).to have_selector(".picker-prompt")
      data_picker.find(".picker-prompt").click

      polling_officers.each do |polling_officer|
        data_picker_choose_value(polling_officer.id)
      end
      data_picker_close

      expect(polling_officers_picker).to have_polling_officers_picked(polling_officers)
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::PollingOfficersPicker, type: :system
end
