# frozen_string_literal: true

module Decidim
  # This class deals with uploading the organization's logo.
  class OrganizationLogoUploader < ImageUploader
    version :medium do
      process resize_to_fit: [600, 160]
    end
  end
end
