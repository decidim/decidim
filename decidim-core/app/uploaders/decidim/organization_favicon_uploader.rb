# frozen_string_literal: true

module Decidim
  # This class deals with uploading an organization's favicon.
  class OrganizationFaviconUploader < ImageUploader
    SIZES = {
      big: 152,
      medium: 64,
      small: 32
    }.freeze

    SIZES.each do |name, size|
      version name do
        process resize_and_pad: [size, size]
      end
    end
  end
end
