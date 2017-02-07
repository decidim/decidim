# frozen_string_literal: true
module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OfficialImageUploader < ImageUploader
    include CarrierWave::MiniMagick

    def max_image_height_or_width
      250
    end
  end
end
