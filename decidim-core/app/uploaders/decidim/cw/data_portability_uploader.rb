# frozen_string_literal: true

module Decidim::Cw
  # This class deals with saving data portability Zip Files to App
  class DataPortabilityUploader < ApplicationUploader
    # Override the directory where uploaded files will be stored.
    def store_dir
      default_path = "uploads/data-portability/"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

      default_path
    end
  end
end
