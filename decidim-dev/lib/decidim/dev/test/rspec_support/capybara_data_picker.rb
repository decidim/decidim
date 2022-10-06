# frozen_string_literal: true

module Capybara
  module DataPicker
    def select_data_picker(id, multiple: nil, global_value: "")
      Struct.new(:data_picker, :global_value).new(find_data_picker(id, multiple:), global_value)
    end

    def find_data_picker(id, multiple: nil)
      if multiple.nil?
        expect(page).to have_selector("div.data-picker[id$='#{id}']")
      else
        expect(page).to have_selector("div.data-picker.picker-#{multiple ? "multiple" : "single"}[id$='#{id}']")
      end
      first("div.data-picker[id$='#{id}']")
    end

    def data_picker_pick_current
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal .picker-footer a[data-picker-choose]", wait: 2)
      body.find("#data_picker-modal .picker-footer a[data-picker-choose]").click
    end

    def data_picker_choose_value(value)
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal input[data-picker-choose][type=checkbox][value=\"#{value}\"]")
      body.find("#data_picker-modal input[data-picker-choose][type=checkbox][value=\"#{value}\"]").click
    end

    def data_picker_close
      body = find(:xpath, "//body")
      expect(body).to have_selector("#data_picker-modal .picker-footer a[data-close]")
      body.find("#data_picker-modal .picker-footer a[data-close]").click
    end
  end
end
