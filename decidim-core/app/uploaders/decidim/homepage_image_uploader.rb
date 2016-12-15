# frozen_string_literal: true
module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class HomepageImageUploader < ImageUploader
    include CarrierWave::MiniMagick

    version :big do
      process resize_to_limit: [nil, 2000]
    end
  end
end
