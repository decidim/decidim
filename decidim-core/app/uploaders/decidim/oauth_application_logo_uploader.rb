# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OAuthApplicationLogoUploader < ImageUploader
    process resize_to_fit: [75, 75]
  end
end
