# frozen_string_literal: true

module Decidim
  # This class deals with uploading hero images to ParticipatoryProcesses.
  class ImageUploader < ApplicationUploader
    include CarrierWave::MiniMagick

    process :validate_size, :validate_dimensions, :strip
    process quality: Decidim.image_uploader_quality

    # CarrierWave automatically calls this method and validates the content
    # type fo the temp file to match against any of these options.
    def content_type_whitelist
      extension_whitelist.map { |ext| "image/#{ext}" }
    end

    # Strips out all embedded information from the image
    def strip
      manipulate! do |img|
        img.strip
        img
      end
    end

    # Add a white list of extensions which are allowed to be uploaded.
    # For images you might use something like this:
    def extension_whitelist
      %w(jpg jpeg gif png bmp ico)
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
        validation_error!(I18n.t("carrierwave.errors.image_too_big")) if image.size > Decidim.maximum_attachment_size
        image
      end
    end

    def max_image_height_or_width
      3840
    end

    def manipulate!
      begin
        super
      rescue CarrierWave::ProcessingError => e
        STDERR.puts e.inspect
        raise CarrierWave::ProcessingError.new('Error processing image')
      end
    end

    private

    def validation_error!(text)
      model.errors.add(mounted_as, text)
      raise CarrierWave::IntegrityError, text
    end
  end
end
