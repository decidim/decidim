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
        {
          resize_and_pad: [value, value],
          format: :png
        }
      end.merge(
        favicon: {
          resize_and_pad: [256, 256],
          define: "icon:auto-resize=16,24,32,48,64,72,96,128,256",
          format: :ico
        }
      )
    end

    def extension_allowlist
      %w(png jpg jpeg ico)
    end
  end
end
