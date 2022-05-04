# frozen_string_literal: true

module Decidim::Cw
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class ImageUploader < ApplicationUploader
    process :validate_size, :validate_dimensions, :strip
    process quality: Decidim.image_uploader_quality

    def validable_dimensions
      true
    end

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_allowlist
      extension_allowlist.map { |ext| "image/#{ext}" }
    end

    # Strips out all embedded information from the image
    def strip
      manipulate! do |img|
        img.strip
        img
      end
    end

    # Fetches info about different variants, their processors and dimensions
    def dimensions_info
      return if variants.blank?

      variants.transform_values do |variant|
        {
          processor: variant.keys.first,
          dimensions: variant.values.first
        }
      end
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    def extension_allowlist
      Decidim.organization_settings(model).upload_allowed_file_extensions_image
    end

    # A simple check to avoid DoS with maliciously crafted images, or just to
    # avoid reckless users that upload gigapixels images.
    #
    # See https://hackerone.com/reports/390
    def validate_dimensions
      manipulate! do |image|
        validation_error!(I18n.t("carrierwave.errors.file_resolution_too_large")) if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }
        image
      end
    end

    def validate_size
      manipulate! do |image|
        validation_error!(I18n.t("carrierwave.errors.file_size_too_large")) if image.size > maximum_upload_size
        image
      end
    end

    def max_image_height_or_width
      3840
    end

    private

    def validation_error!(text)
      model.errors.add(mounted_as, text)
      raise CarrierWave::IntegrityError, text
    end

    def maximum_upload_size
      Decidim.organization_settings(model).upload_maximum_file_size
    end
  end
end
