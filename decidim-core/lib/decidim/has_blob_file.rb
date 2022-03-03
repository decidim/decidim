# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Concern for form objects and commands to handle conversion from a signed_id to a blob.
  #
  # When adding files from UI we add signed id of ActiveStorage::Blob to form (and thus to the parameters).
  # After we want to process the file in form or command we can find the blob via it's signed_id.
  module HasBlobFile
    extend ActiveSupport::Concern

    private

    def blob
      @blob ||= begin
        return file if defined?(file) && file.is_a?(ActiveStorage::Blob)
        return @form.file if @form.present? && @form.respond_to?(:file) && @form.file.is_a?(ActiveStorage::Blob)
        return ActiveStorage::Blob.find_signed(file_signed_id) if file_signed_id.is_a?(String)

        file_signed_id
      end
    end

    def blob_path
      ActiveStorage::Blob.service.path_for(blob.key)
    end

    def file_signed_id
      @file_signed_id ||= begin
        return file if defined?(file) && file.is_a?(String)
        return @form.file if @form.file.is_a?(String)
      end
    end
  end
end
