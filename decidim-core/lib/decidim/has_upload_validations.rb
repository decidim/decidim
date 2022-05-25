# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasUploadValidations
    extend ActiveSupport::Concern

    class_methods do
      def validates_upload(attribute, options = {})
        max_size = options.delete(:max_size) || ->(record) { record.maximum_upload_size }

        validates(
          attribute,
          file_size: { less_than_or_equal_to: max_size },
          organization_present: true,
          uploader_content_type: true,
          uploader_image_dimensions: true
        )

        attached_config[attribute] = OpenStruct.new(options)
        validate_config(attached_config[attribute], attribute)
      end

      def validates_avatar(attribute = :avatar, options = {})
        validates_upload(
          attribute,
          **options.merge(max_size: ->(record) { record.maximum_avatar_size })
        )
      end

      def attached_config
        @attached_config ||= superclass.respond_to?(:attached_config) ? superclass.attached_config.dup : {}
      end

      def attached_options(attached, options = {})
        attached_config[attached] = OpenStruct.new(options)

        yield(attached_config[attached]) if block_given?
      end

      private

      def validate_config(config, attribute)
        valid_keys = [:uploader]
        unknown_keys = config.to_h.keys - valid_keys
        return if unknown_keys.blank?

        raise ArgumentError, "Invalid uploader configuration keys found for #{attribute} on #{name}: #{unknown_keys.join(",")}. Allowed keys: #{valid_keys.join(",")}"
      end
    end

    delegate :attached_config, to: :class

    def attached_uploader(attached_name)
      uploader = attached_config.dig(attached_name, :uploader) || Decidim::ApplicationUploader

      uploader.new(self, attached_name)
    end

    def maximum_upload_size
      Decidim.organization_settings(organization).upload_maximum_file_size
    end

    def maximum_avatar_size
      Decidim.organization_settings(organization).upload_maximum_file_size_avatar
    end
  end
end
