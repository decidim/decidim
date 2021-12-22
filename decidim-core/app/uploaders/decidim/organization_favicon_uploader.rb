# frozen_string_literal: true

module Decidim
  # This class deals with uploading an organization's favicon.
  class OrganizationFaviconUploader < ImageUploader
    SIZES = {
      big: 192,
      medium: 180,
      small: 32
    }.freeze

    def extension_allowlist
      Decidim.organization_settings(model).upload_allowed_file_extensions_favicon
    end

    set_variants do
      SIZES.transform_values do |value|
        { resize_and_pad: [value, value] }
      end
    end
  end
end
