# frozen_string_literal: true

# Adapted from https://github.com/JedWatson/react-select/issues/832#issuecomment-276441836

module Capybara
  module UploadModal
    # Replaces attach_file.
    # Beware that modal does not open within form!
    def dynamically_attach_file(value, file_name)
      find("##{value}").click

      within ".attachment-modal" do
        attach_file Decidim::Dev.asset(file_name) do
          find(".dropzone").click
        end
        expect(page).to have_content("Uploaded")
        click_button "Save"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::UploadModal, type: :system
end
