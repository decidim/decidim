# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OfficialImageHeaderUploader < ImageUploader
    include CarrierWave::MiniMagick
    process resize_to_fit: [160, 160]
  end
end
