# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusDataForm < Form
          include Decidim::HasUploadValidations
          include Decidim::ProcessesFileLocally
          mimic :census_data

          attribute :file, Decidim::Attributes::Blob

          validates :file, presence: true, file_content_type: { allow: ["text/csv"] }

          def data
            @data ||= process_data
          end

          def process_data
            process_file_locally(file) do |file_path|
              CsvCensus::Data.new(file_path)
            end
          rescue CSV::MalformedCSVError
            errors.add(:file, :malformed)
          end

          def validate_csv
            return unless data

            errors.add(:base, I18n.t("decidim.verifications.errors.wrong_number_columns", expected: 1, actual: data.count)) if data.count != 1

            errors.add(:base, I18n.t("decidim.verifications.errors.no_emails")) if data.values.empty?

            data.values.each do |value|
              errors.add(:base, I18n.t("decidim.verifications.errors.invalid_emails", invalid_emails: value)) unless valid_email?(value)
            end
          end

          private

          def valid_email?(email)
            URI::MailTo::EMAIL_REGEXP.match?(email)
          end
        end
      end
    end
  end
end
