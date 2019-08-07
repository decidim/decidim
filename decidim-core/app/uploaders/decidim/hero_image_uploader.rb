# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class HeroImageUploader < ImageUploader
    process resize_to_limit: [1000, 1000]
  end
end
