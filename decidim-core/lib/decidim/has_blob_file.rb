# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasBlobFile
    extend ActiveSupport::Concern

    def blob
      @blob ||= begin
        return file if file.is_a? ActiveStorage::Blob
        return @form.file if @form.present? && @form.respond_to?(:file) && @form.file.is_a?(ActiveStorage::Blob)
        return ActiveStorage::Blob.find_signed(files_signed_id) if files_signed_id.is_a? String

        files_signed_id
      end
    end

    def files_signed_id
      @files_signed_id ||= begin
        return file if file.is_a? String
        return @form.file if @form.file.is_a? String
      end
    end
  end
end
