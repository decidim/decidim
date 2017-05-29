# frozen_string_literal: true

module Decidim
  # This class deals with uploading banner images to ParticipatoryProcesses.
  class BannerImageUploader < ImageUploader
    process resize_to_limit: [1000, 200]
  end
end
