# frozen_string_literal: true

module Decidim
  # This class fetches the file validation conditions from the active record
  # model objects which have specific validators and uploaders attached to them.
  # This class is used to convert these validation conditions to a human
  # readable format in the front-end and to simplify the code where these are
  # needed from.
  #
  # This considers if the validation conditions and the uploader have been set
  # directly to the record being validated or if they should be read from
  # another object in case the PassthruValidator is in charge of the
  # validations.
  class FileValidatorHumanizer
    # record - Form object (e.g. Decidim::AccountForm)
    # attribute - Form field (e.g. :avatar)
    def initialize(record, attribute)
      @record = record
      @attribute = attribute
      @passthru_validator ||= record.singleton_class.validators_on(
        attribute
      ).find { |validator| validator.is_a?(PassthruValidator) }
    end

    def uploader
      @uploader ||= fetch_uploader
    end

    def messages
      messages = []

      if (file_size = max_file_size)
        file_size_mb = (((file_size / 1024 / 1024) * 100) / 100).round
        messages << I18n.t(
          "max_file_size",
          megabytes: file_size_mb,
          scope: "decidim.forms.file_validation"
        )
      end

      if (file_dimensions = max_file_dimensions)
        messages << I18n.t(
          "max_file_dimension",
          resolution: file_dimensions,
          scope: "decidim.forms.file_validation"
        )
      end

      if (extensions = extension_allowlist)
        messages << I18n.t(
          "allowed_file_extensions",
          extensions: extensions.join(" "),
          scope: "decidim.forms.file_validation"
        )
      end

      messages
    end

    # rubocop: disable Metrics/CyclomaticComplexity
    def max_file_size
      # First try if the record itself has a file size validator defined.
      validator = record.singleton_class.validators_on(attribute).find do |v|
        v.is_a?(::ActiveModel::Validations::FileSizeValidator)
      end
      if validator
        lte = validator.options[:less_than_or_equal_to]
        return lte if lte.is_a?(Numeric)
        return lte.call(record) if lte.respond_to?(:call)
      end
      return unless passthru_validator

      # If not, check for the same validator from the pass through record.
      validator = passthru_validator.target_validators(attribute).find do |v|
        v.is_a?(::ActiveModel::Validations::FileSizeValidator)
      end
      return unless validator

      lte = validator.options[:less_than_or_equal_to]
      return lte if lte.is_a?(Numeric)

      lte.call(passthru_record) if lte.respond_to?(:call)
    end
    # rubocop: enable Metrics/CyclomaticComplexity

    def max_file_dimensions
      return unless uploader.respond_to?(:max_image_height_or_width)

      "#{uploader.max_image_height_or_width}x#{uploader.max_image_height_or_width}"
    end

    def extension_allowlist
      return unless uploader.respond_to?(:extension_allowlist, true)

      # It may be a private method in some uploaders which is why we need to use
      # `#send`.
      uploader.send(:extension_allowlist)
    end

    private

    attr_reader :record, :attribute, :passthru_validator

    def fetch_uploader
      return passthru_uploader if passthru_uploader.present?
      return record.attached_uploader(attribute) if record.respond_to?(:attached_uploader) && record.attached_uploader(attribute).present?

      record.send(attribute)
    end

    def passthru_record
      return unless passthru_validator

      @passthru_record ||= passthru_validator.validation_record(record)
    end

    def passthru_uploader
      return unless passthru_record

      passthru_attribute = passthru_validator.target_attribute(attribute)
      passthru_record.attached_uploader(passthru_attribute) || passthru_record.send(passthru_attribute)
    end
  end
end
