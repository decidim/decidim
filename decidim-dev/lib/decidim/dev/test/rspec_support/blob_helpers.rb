# frozen_string_literal: true

# Adapted from https://github.com/JedWatson/react-select/issues/832#issuecomment-276441836

module Capybara
  module BlobHelpers
    # Creates blob and returns it's signed_id
    def upload_test_file(file, options = {})
      filename = options[:filename] || solve_filename(file)
      content_type = options[:content_type] || file.content_type

      blob = ActiveStorage::Blob.create_after_upload!(
        io: File.open(file),
        filename: filename,
        content_type: content_type
      )
      blob.signed_id
    end

    private

    def solve_filename(file)
      return file.original_filename if file.respond_to? :original_filename

      file.split("/").last
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::BlobHelpers
end
