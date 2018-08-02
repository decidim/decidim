# frozen_string_literal: true

module Decidim
  # This class deals with uploading banner images to ParticipatoryProcesses.
  class BannerImageUploader < ImageUploader
    process resize_to_limit: [1200, 600]
    process quality: 60
  end
end
