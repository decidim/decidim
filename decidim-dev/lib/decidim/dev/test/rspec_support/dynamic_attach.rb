# frozen_string_literal: true

# Adapted from https://github.com/JedWatson/react-select/issues/832#issuecomment-276441836

module Capybara
  module UploadModal
    # Replaces attach_file.
    # Beware that modal does not open within form!
    def dynamically_attach_file(name, file_location, options = {})
      find("##{name}_button").click
      filename = options[:filename] || file_location.to_s.split("/").last

      yield if block_given?

      within ".upload-modal" do
        find(".remove-upload-item").click if options[:remove_before]
        input_element = find("input[type='file']", visible: :all)
        input_element.attach_file(file_location)
        within "[data-filename='#{filename}']" do
          expect(page).to have_css("div.progress-bar.filled", wait: 5)
        end
        all("input.attachment-title").last.set(options[:title]) if options.has_key?(:title)
        click_button "Save" unless options[:keep_modal_open]
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::UploadModal, type: :system
end
