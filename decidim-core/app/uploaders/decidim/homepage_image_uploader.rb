# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class HomepageImageUploader < ImageUploader
    include CarrierWave::MiniMagick

    version :big do
      process resize_to_fill: [1920, 666]
    end

    def max_image_height_or_width
      8000
    end
  end
end
