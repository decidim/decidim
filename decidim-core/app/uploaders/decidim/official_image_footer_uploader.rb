# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class OfficialImageFooterUploader < ImageUploader
    process resize_to_fit: [600, 180]
  end
end
