# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to organizations.
  class HomepageImageUploader < RecordImageUploader
    set_variants do
      { big: { resize_to_fill: [1920, 666] } }
    end

    def max_image_height_or_width
      8000
    end
  end
end
