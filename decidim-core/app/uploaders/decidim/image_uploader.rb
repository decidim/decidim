# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class ImageUploader < ApplicationUploader
    process :validate_size, :validate_dimensions, :strip
    process quality: Decidim.image_uploader_quality

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

    # Fetches info about different versions, their processors and dimensions
    def dimensions_info
      if versions.any?
        versions.transform_values do |info|
          {
            processor: info.processors[0][0],
            dimensions: info.processors[0][1]
          }
        end
      else
        processors.map do |info|
          [:default, { processor: info[0], dimensions: info[1] }]
        end.to_h
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
        validation_error!(I18n.t("carrierwave.errors.image_too_big")) if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }
        image
      end
    end

    def validate_size
      manipulate! do |image|
        validation_error!(I18n.t("carrierwave.errors.image_too_big")) if image.size > maximum_upload_size
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
