# frozen_string_literal: true

# This validator checks when the files to be uploaded are images and the attached uploader's
# has enabled dimensions validation that the image dimensions are below the
# limit defined by the uploader
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
    return unless file.is_a? ActionDispatch::Http::UploadedFile
    return unless file.content_type.to_s.start_with? "image"

    image = MiniMagick::Image.new(file.path)
    record.errors.add attribute, :invalid if image.dimensions.any? { |dimension| dimension > uploader.max_image_height_or_width }
  end

  def check_validity!; end
end
