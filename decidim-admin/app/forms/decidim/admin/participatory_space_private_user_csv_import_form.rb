# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      include Decidim::HasUploadValidations
      include Decidim::Admin::CustomImport

      attribute :file, Decidim::Attributes::Blob
      attribute :user_name, String
      attribute :email, String

      validates :file, presence: true, file_content_type: { allow: ["text/csv"] }
      validate :validate_csv

      def validate_csv
        return if file.blank?

        process_import_file(file) do |(_email, user_name)|
          errors.add(:user_name, :invalid) if user_name.blank? || !user_name.match?(UserBaseEntity::REGEXP_NAME)
        end
      end
    end
  end
end
