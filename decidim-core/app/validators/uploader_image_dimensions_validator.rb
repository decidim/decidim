# frozen_string_literal: true

# This validator checks when the files to be uploaded are images and the attached uploader's
# has enabled dimensions validation that the image dimensions are below the
# limit defined by the uploader
require "mini_magick"

class UploaderImageDimensionsValidator < ActiveModel::Validations::FileContentTypeValidator
  def validate_each(record, attribute, value)
    begin
      values = parse_values(value)
    rescue JSON::ParserError
      record.errors.add attribute, :invalid
      return
    end

    return if values.empty?

    uploader = record.attached_uploader(attribute) || record.send(attribute)
    return unless uploader.is_a?(Decidim::ApplicationUploader)

    values.each do |val|
      validate_image_size(record, attribute, val, uploader)
    end
  end

  def validate_image_size(record, attribute, file, uploader)
    return unless uploader.validable_dimensions
    return if (image = extract_image(file)).blank?

    record.errors.add attribute, I18n.t("carrierwave.errors.file_resolution_too_large") if image.dimensions.any? { |dimension| dimension > uploader.max_image_height_or_width }
  end

  def extract_image(file)
    return unless file.try(:content_type).to_s.start_with?("image")

    if file.is_a?(ActionDispatch::Http::UploadedFile)
      MiniMagick::Image.new(file.path)
    elsif file.is_a?(ActiveStorage::Attached) && file.blob.persisted?
      MiniMagick::Image.read(file.blob.download)
    end
  rescue ActiveStorage::FileNotFoundError
    # Although the blob is persisted, the file is not available to download and analyze
    # after committing the record
    nil
  end

  def check_validity!; end
end
