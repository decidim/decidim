# frozen_string_literal: true

module Decidim
  module Conferences
    # This class deals with uploading the conference partner logo.
    class PartnerLogoUploader < ImageUploader
      version :thumb do
        process resize_to_fit: [200, 55]
      end
      version :medium do
        process resize_to_fit: [600, 160]
      end
    end
  end
end
