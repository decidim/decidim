# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasUploadValidations
    extend ActiveSupport::Concern

    class_methods do
      def validates_upload(attribute, options = {})
        max_size = options[:max_size] || ->(record) { record.maximum_upload_size }

        validates(
          attribute,
          file_size: { less_than_or_equal_to: max_size },
          uploader_content_type: true
        )
      end

      def validates_avatar(attribute = :avatar)
        validates_upload(
          attribute,
          max_size: ->(record) { record.maximum_avatar_size }
        )
      end
    end

    def maximum_upload_size
      Decidim.organization_settings(organization).upload_maximum_file_size
    end

    def maximum_avatar_size
      Decidim.organization_settings(organization).upload_maximum_file_size_avatar
    end
  end
end
