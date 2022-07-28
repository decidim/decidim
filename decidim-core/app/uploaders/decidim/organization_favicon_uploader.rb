# frozen_string_literal: true

module Decidim
  # This class deals with uploading an organization's favicon.
  class OrganizationFaviconUploader < ImageUploader
    SIZES = {
      huge: 512,
      big: 192,
      medium: 180,
      small: 32
    }.freeze

    set_variants do
      SIZES.transform_values do |value|
        { resize_and_pad: [value, value] }
      end
    end

    def extension_allowlist
      %w(jpg jpeg gif png ico)
    end
  end
end
