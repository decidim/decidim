# frozen_string_literal: true

require "csv"

module Decidim
  module Admin
    # A form object used to upload CSV to batch participatory space private users.
    #
    class ParticipatorySpacePrivateUserCsvImportForm < Form
      include Decidim::HasUploadValidations
      include Decidim::ProcessesFileLocally

      attribute :file, Decidim::Attributes::Blob
      attribute :user_name, String
      attribute :email, String

      validates :file, presence: true, file_content_type: { allow: ["text/csv"] }
      validate :validate_csv

      def validate_csv
        return if file.blank?

        process_file_locally(file) do |file_path|
          CSV.foreach(file_path) do |_email, user_name|
            errors.add(:user_name, :invalid) unless user_name.match?(UserBaseEntity::REGEXP_NAME)
          end
        end
      end
    end
  end
end
