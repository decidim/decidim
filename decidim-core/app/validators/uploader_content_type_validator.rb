# frozen_string_literal: true

# This validator ensures the files to be uploaded match the attached uploader's
# content types.
class UploaderContentTypeValidator < ActiveModel::Validations::FileContentTypeValidator
  # rubocop: disable Metrics/CyclomaticComplexity
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

      # The :strict mode would be more robust for the content type detection if
      # the value does not know its own content type. However, this would
      # require the command line utility named `file` which is only available in
      # *nix. This would also require adding a new gem dependency for running
      # the CLI utility, Terrapin or Cocaine in older versions of the
      # file_validators gem. The :relaxed mode detects the content type based on
      # the file extension through the mime-types gem.
      val_mode = :relaxed if val_mode.blank? && !val.respond_to?(:content_type)

      content_type = get_content_type(val, val_mode)
      validate_whitelist(record, attribute, content_type, allowed_types)
      validate_blacklist(record, attribute, content_type, forbidden_types)
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity

  def check_validity!; end

  private

  # This fixes the "weird" error messages such as "(?-mix:image\\/.*)" because
  # this is the notation Regexp#to_s will return. Instead, we want to show the
  # inner contents of the regular expressions.
  def mark_invalid(record, attribute, error, option_types)
    allowed_extensions = Decidim.organization_settings(record).upload_allowed_file_extensions
    extensions = []
    content_types = []
    option_types.each do |type|
      if (exts = content_type_extensions(type, allowed_extensions))
        extensions += exts.map { |ext| "*.#{ext}" }
      else
        content_types << type
      end
    end
    super(record, attribute, error, (extensions.sort + content_types.sort))
  end

  # Resolves the content type extensions through MiniMime or looks up all the
  # possible extensions for wildcard content types such as `image/*`. For the
  # wildcard extension types only those listed in the `allowed_extensions` will
  # be returned.
  #
  # @param content_type [String] The content type, such as application/pdf or
  #   image/*.
  # @param allowed_extensions [Array] An array of all the extensions allowed for
  #   the record.
  # @return [Array, nil] An array of the allowed extensions or nil when no
  #   extensions could be found.
  def content_type_extensions(content_type_match, allowed_extensions)
    # Since the original content types may have endings such as image/.*?, we
    # want to replace the regexp pattern just with a star with the fallback
    # option.
    content_type = (content_type_match.try(:source) || content_type_match.to_s).gsub(".*?", "*")
    if content_type.ends_with?("/*")
      main_type = content_type.split("/")[0]
      extensions = extensions_matching(%r{#{main_type}/.*}) & allowed_extensions
      return if extensions.count.zero?

      return extensions
    end

    extensions_matching(content_type) & allowed_extensions
  end

  # Looks up the extensions matching the content type lookup based on the
  # MiniMime content types.
  def extensions_matching(content_type_lookup)
    extensions = []
    File.open(MiniMime::Configuration.ext_db_path).each do |line|
      info = line.split(/\s+/)
      next unless info[1].match?(content_type_lookup)

      extensions << info[0]
    end

    extensions
  end
end
