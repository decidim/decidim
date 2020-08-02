# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module HasUploadValidations
    extend ActiveSupport::Concern

    class_methods do
      def validates_upload(attribute)
        validates(
          attribute,
          file_size: { less_than_or_equal_to: ->(record) { record.maximum_upload_size } },
          uploader_content_type: true
        )
      end
    end

    def maximum_upload_size
      Decidim.organization_settings(organization).upload_maximum_file_size
    end
  end
end
