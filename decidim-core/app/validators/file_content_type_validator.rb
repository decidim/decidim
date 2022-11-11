# frozen_string_literal: true

# We need to define the validator in the `ActiveModel::Validations` namespace as
# this is what the `file_validators` uses and this is what gets priority over
# the root namespace class.
module ActiveModel
  module Validations
    # This validator provides content type validation for uploaded files. Extends
    # the validator provided by the `file_validators` gem by fixing some weird
    # messages in that validator.
    class FileContentTypeValidator
      private

      alias mark_invalid_original mark_invalid unless private_method_defined?(:mark_invalid_original)

      # This fixes the "weird" error messages such as "(?-mix:image\\/.*)" because
      # this is the notation Regexp#to_s will return. Instead, we want to show the
      # inner contents of the regular expressions.
      #
      # @see ActiveModel::Validations::FileContentTypeValidator#mark_invalid
      def mark_invalid(record, attribute, error, option_types)
        mark_invalid_original(record, attribute, error, invalid_types(option_types))
      end

      # Converts the configured content type matches to extensions if extensions are
      # recognized for the specified content type and if not, the content type
      # string itself.
      #
      # @param option_types [Array<Regexp, String>] Array of configured types.
      # @param allowed_extensions [Array<String>, nil] Array of allowed extensions
      #   or nil if all extensions are "allowed" (in case we want to show the
      #   denylist error or hard code the types).
      # @return [Array<String>] The invalid types as strings.
      def invalid_types(option_types, allowed_extensions = nil)
        extensions = []
        content_types = []
        option_types.each do |type|
          # Since the original content types may have endings such as image/.*?, we
          # want to replace the regexp pattern just with a star with the fallback
          # option.
          content_type = (type.try(:source) || type.to_s).gsub(".*?", "*")
          if (exts = content_type_extensions(content_type, allowed_extensions))
            extensions += exts
          else
            content_types << content_type
          end
        end

        extensions.sort + content_types.sort
      end

      # Resolves the content type extensions through MiniMime or looks up all the
      # possible extensions for wildcard content types such as `image/*`. For the
      # wildcard extension types only those listed in the `allowed_extensions` will
      # be returned.
      #
      # @param content_type [String] The content type, such as application/pdf or
      #   image/*.
      # @param allowed_extensions [Array, nil] Array of allowed extensions
      #   or nil if all extensions are "allowed" (in case we want to show the
      #   denylist error or hard code the types).
      # @return [Array<String>, nil] An array of the allowed extensions or nil when
      #   no extensions could be found.
      def content_type_extensions(content_type, allowed_extensions = nil)
        extensions =
          if content_type.ends_with?("/*")
            main_type = content_type.split("/")[0]
            extensions_matching(%r{#{main_type}/.*})
          else
            extensions_matching(content_type)
          end
        return if extensions.count.zero?
        return extensions unless allowed_extensions

        extensions & allowed_extensions
      end

      # Looks up the extensions matching the content type lookup based on the
      # MiniMime content types.
      #
      # @param content_type_lookup [String, Regexp] The lookup to be matched
      #   against.
      # @return [Array<String>] The array of extensions.
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
  end
end

# This is just to make Zeitwerk happy. The actual validator that gets priority
# is the class above as all validators in the `ActiveModel::Validations`
# namespace will be used primarily and only if a matching validator is not found
# in that namespace, the ones at the root level are used.
class FileContentTypeValidator < ActiveModel::Validations::FileContentTypeValidator; end
