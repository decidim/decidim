# frozen_string_literal: true

# This validator ensures the files to be uploaded match the attached uploader's
# content types. This prevents CarrierWave from uploading the records before
# they pass the content type validations.
class UploaderContentTypeValidator < ActiveModel::Validations::FileContentTypeValidator
  def validate_each(record, attribute, value)
    begin
      values = parse_values(value)
    rescue JSON::ParserError
      record.errors.add attribute, :invalid
      return
    end

    return if values.empty?

    uploader = record.send(attribute)
    return unless uploader

    mode = option_value(record, :mode)
    allowed_types = uploader.content_type_whitelist || []
    forbidden_types = uploader.content_type_blacklist || []

    values.each do |val|
      content_type = get_content_type(val, mode)
      validate_whitelist(record, attribute, content_type, allowed_types)
      validate_blacklist(record, attribute, content_type, forbidden_types)
    end
  end

  def check_validity!; end
end
