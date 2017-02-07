# frozen_string_literal: true
module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OfficialImageFooterUploader < ImageUploader
    include CarrierWave::MiniMagick
    process resize_to_limit: [150, 45]

    def max_image_height_or_width
      300
    end
  end
end
