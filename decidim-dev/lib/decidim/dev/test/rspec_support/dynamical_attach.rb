# frozen_string_literal: true

# Adapted from https://github.com/JedWatson/react-select/issues/832#issuecomment-276441836

module Capybara
  module UploadModal
    # Replaces attach_file.
    # Beware that modal does not open within form!
    def dynamically_attach_file(value, file_location)
      find("##{value}").click

      within ".attachment-modal" do
        input_element = find("input[type='file']", visible: :all)
        input_element.attach_file file_location
        expect(page).to have_css("div.progress-bar.filled", wait: 5)
        click_button "Save"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::UploadModal, type: :system
end
