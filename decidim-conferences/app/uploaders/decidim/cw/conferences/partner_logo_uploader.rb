# frozen_string_literal: true

module Decidim::Cw
  module Conferences
    # This class deals with uploading the conference partner logo.
    class PartnerLogoUploader < Decidim::Cw::ImageUploader
      set_variants do
        {
          thumb: { resize_to_fit: [200, 55] },
          medium: { resize_to_fit: [600, 160] }
        }
      end
    end
  end
end
