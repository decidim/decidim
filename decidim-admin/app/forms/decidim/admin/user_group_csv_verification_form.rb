# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to upload CSV to batch verify user groups.
    #
    class UserGroupCsvVerificationForm < Form
      include Decidim::HasUploadValidations
      include Decidim::ProcessesFileLocally

      attribute :file, Decidim::Attributes::Blob

      validates :file, presence: true, file_content_type: { allow: ["text/csv"] }
      validate :validate_csv, unless: ->(f) { f.file.blank? }

      def validate_csv
        process_file_locally(file) do |file_path|
          CSV.open(file_path, &:readline)
        end
      rescue CSV::MalformedCSVError
        errors.add(:file, :malformed)
      end
    end
  end
end
