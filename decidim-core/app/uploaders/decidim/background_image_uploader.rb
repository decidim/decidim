# frozen_string_literal: true

module Decidim
  # This class deals with uploading background images to participatory spaces, to be used with the ParticipatorySpaceHero
  # content block.
  class BackgroundImageUploader < RecordImageUploader
    set_variants do
      { default: { resize_to_fit: [1000, 1000] } }
    end
  end
end
