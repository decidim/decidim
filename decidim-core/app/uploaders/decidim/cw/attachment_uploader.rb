# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading attachments to a participatory space.
  class AttachmentUploader < ApplicationUploader
    process :validate_dimensions
    process :strip

    def validable_dimensions
      true
    end

    set_variants do
      {
        thumbnail: { resize_to_fit: [nil, 237] },
        big: { resize_to_limit: [nil, 1000] }
      }
    end

    def max_image_height_or_width
      8000
    end

    protected

    # Strips out all embedded information from the image
    def strip
      return unless image?(self)

      manipulate! do |img|
        img.strip
        img
      end
    end

    def upload_context
      return :participant unless model.respond_to?(:context)

      model.context
    end

    # A simple check to avoid DoS with maliciously crafted images, or just to
    # avoid reckless users that upload gigapixels images.
    #
    # See https://hackerone.com/reports/390
    def validate_dimensions
      return unless image?(self)

      manipulate! do |image|
        raise CarrierWave::IntegrityError, I18n.t("carrierwave.errors.file_resolution_too_large") if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }

        image
      end
    end
  end
end
