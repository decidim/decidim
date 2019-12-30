# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OfficialImageHeaderUploader < ImageUploader
    process resize_to_fit: [160, 160]
  end
end
