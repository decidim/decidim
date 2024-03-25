# frozen_string_literal: true

module Decidim
  class ValidateUpload < Decidim::Command
    def initialize(form)
      @form = form
    end

    def call
      if @form.invalid?
        remove_invalid_file
        return broadcast(:invalid, @form.errors)
      end

      broadcast(:ok)
    end

    private

    def remove_invalid_file
      blob = ActiveStorage::Blob.find_signed(@form.blob)
      blob.purge if blob.present?
    end
  end
end
