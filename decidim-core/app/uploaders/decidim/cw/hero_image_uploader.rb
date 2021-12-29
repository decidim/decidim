# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class HeroImageUploader < RecordImageUploader
    set_variants do
      { default: { resize_to_fit: [1000, 1000] } }
    end
  end
end
