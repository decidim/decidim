# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class CensusDataForm < Decidim::Form
        include Decidim::HasUploadValidations
        include Decidim::ProcessesFileLocally
        include Decidim::Admin::CustomImport

        mimic :census_data

        attribute :file, Decidim::Attributes::Blob

        validates :file, presence: true, file_content_type: { allow: ["text/csv"] }

        validate :validate_csv

        def validate_csv
          return if file.blank?

          process_import_file(file) do |(email, token)|
            errors.add(:email, :invalid) if email.blank? || token.blank?
          end
        rescue CSV::MalformedCSVError
          errors.add(:file, :malformed)
        end

        def data
          return [] if file.blank?

          parsed = []

          process_import_file(file) do |(email, token)|
            next if email.blank? || token.blank?

            parsed << [email.strip.downcase, token.strip]
          end

          parsed
        end
      end
    end
  end
end
