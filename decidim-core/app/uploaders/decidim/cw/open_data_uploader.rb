# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading open data.
  class OpenDataUploader < ApplicationUploader
    protected

    # Override the directory where uploaded files will be stored. We only want one copy of the Open Data
    # export.
    def store_dir
      default_path = "uploads/open-data"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

      default_path
    end

    # Sets the validation that the associated model is always within an organization to true
    def validate_inside_organization
      true
    end
  end
end
