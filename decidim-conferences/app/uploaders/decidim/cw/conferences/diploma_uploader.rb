# frozen_string_literal: true

module Decidim::Cw
  module Conferences
    # This class deals with uploading the conference partner logo.
    class DiplomaUploader < Decidim::Cw::ImageUploader
      set_variants do
        {
          thumb: { resize_to_fit: [275, 90] }
        }
      end
    end
  end
end
