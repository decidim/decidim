# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading an organization's favicon.
  class OrganizationFaviconUploader < ImageUploader
    SIZES = {
      big: 152,
      medium: 64,
      small: 32
    }.freeze

    set_variants do
      SIZES.transform_values do |value|
        { resize_and_pad: [value, value] }
      end
    end
  end
end
