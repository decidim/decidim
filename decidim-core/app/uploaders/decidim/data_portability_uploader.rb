# frozen_string_literal: true

module Decidim
  # This class deals with saving data portability Zip Files to App
  class DataPortabilityUploader < CarrierWave::Uploader::Base
    # Override the directory where uploaded files will be stored.
    # def store_dir
    #   default_path = "tmp/data-portability/"
    #   File.join(Rails.root, default_path)
    # end

    def store_dir
      default_path = "tmp/data-portability/"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?
      default_path
    end
  end
end
