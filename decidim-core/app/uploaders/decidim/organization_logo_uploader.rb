# frozen_string_literal: true
module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OrganizationLogoUploader < ImageUploader
    version :medium do
      process resize_to_limit: [500, 500]
    end
  end
end
