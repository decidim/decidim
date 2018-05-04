# frozen_string_literal: true

module Capybara
  module DataPicker
    def select_data_picker(id, multiple: nil, global_value: "")
      Struct.new(:data_picker, :global_value).new(find_data_picker(id, multiple: multiple), global_value)
    end

    private

    def find_data_picker(id, multiple: nil)
      if multiple.nil?
        expect(page).to have_selector("div.data-picker##{id}")
      else
        expect(page).to have_selector("div.data-picker.picker-#{multiple ? "multiple" : "single"}##{id}")
      end
      find("div.data-picker##{id}")
    end

    def data_picker_pick_current
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal .picker-footer a[data-picker-choose]")
      body.find("#data_picker-modal .picker-footer a[data-picker-choose]").click
    end
  end
end
