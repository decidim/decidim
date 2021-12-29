# frozen_string_literal: true

module Decidim
  module Conferences
    # This class deals with uploading the conference partner logo.
    class PartnerLogoUploader < ImageUploader
      set_variants do
        {
          thumb: { resize_to_fit: [200, 55] },
          medium: { resize_to_fit: [600, 160] }
        }
      end
    end
  end
end
