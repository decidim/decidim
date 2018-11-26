# frozen_string_literal: true

module Decidim
  # This class deals with uploading open data.
  class OpenDataUploader < ApplicationUploader
    protected

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_whitelist
      # [
      #   %r{application\/zip}
      # ]
    end

    # Override the directory where uploaded files will be stored. We only want one copy of the Open Data
    # export.
    def store_dir
      default_path = "uploads/open-data"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?
      default_path
    end
  end
end
