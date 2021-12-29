# frozen_string_literal: true

module Decidim
  module Conferences
    # This class deals with uploading the conference partner logo.
    class DiplomaUploader < ImageUploader
      set_variants do
        {
          thumb: { resize_to_fit: [275, 90] }
        }
      end
    end
  end
end
