# frozen_string_literal: true
module Capybara
  module DataPicker

    private

    def data_picker_find(id, multiple: nil)
      if multiple.nil?
        expect(page).to have_selector("div.data-picker##{id}")
      else
        expect(page).to have_selector("div.data-picker.picker-#{multiple ? "multiple" : "single"}##{id}")
      end
      find("div.data-picker##{id}")
    end
  end
end
