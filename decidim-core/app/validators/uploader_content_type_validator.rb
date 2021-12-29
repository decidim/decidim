# frozen_string_literal: true

# This validator ensures the files to be uploaded match the attached uploader's
# content types.
class UploaderContentTypeValidator < ActiveModel::Validations::FileContentTypeValidator
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
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

    mode = option_value(record, :mode)
    allowed_types = uploader.content_type_allowlist || []
    forbidden_types = uploader.content_type_denylist || []

    values.each do |val|
      val_mode = mode
      blob = val.respond_to?(:blob) ? val.blob : ActiveStorage::Blob.find_signed(val[:file])

      # The :strict mode would be more robust for the content type detection if
      # the value does not know its own content type. However, this would
      # require the command line utility named `file` which is only available in
      # *nix. This would also require adding a new gem dependency for running
      # the CLI utility, Terrapin or Cocaine in older versions of the
      # file_validators gem. The :relaxed mode detects the content type based on
      # the file extension through the mime-types gem.
      val_mode = :relaxed if val_mode.blank? && !blob.respond_to?(:content_type)

      content_type = get_content_type(blob, val_mode)
      validate_whitelist(record, attribute, content_type, allowed_types)
      validate_blacklist(record, attribute, content_type, forbidden_types)
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity

  def check_validity!; end
end
