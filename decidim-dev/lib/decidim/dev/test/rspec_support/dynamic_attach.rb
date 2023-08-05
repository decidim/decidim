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

      front_interface = options.fetch(:front_interface, true)

      within ".upload-modal" do
        click_remove(front_interface) if options[:remove_before]
        input_element = find("input[type='file']", visible: :all)
        input_element.attach_file(file_location)
        within "[data-filename='#{filename}']" do
          expect(page).to have_css(filled_selector(front_interface), wait: 5)
          expect(page).to have_content(filename.first(12)) if front_interface
        end
        all(title_input(front_interface)).last.set(options[:title]) if options.has_key?(:title)
        click_button(front_interface ? "Next" : "Save") unless options[:keep_modal_open]
      end
    end

    def filled_selector(front_interface)
      front_interface ? "li progress[value='100']" : "div.progress-bar.filled"
    end

    def title_input(front_interface)
      front_interface ? "input[type='text']" : "input.attachment-title"
    end

    def click_remove(front_interface)
      front_interface ? click_button("Remove") : find(".remove-upload-item").click
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::UploadModal, type: :system
end
