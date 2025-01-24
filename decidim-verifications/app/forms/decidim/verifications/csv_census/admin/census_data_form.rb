# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusDataForm < Form
          mimic :census_data

          attribute :file

          def data
            @data ||= CsvCensus::Data.new(file.path)
          end

          def csv_must_be_readable
            data.read

            errors.add(:base, I18n.t("decidim.verifications.errors.has_headers")) if data.headers.any?

            errors.add(:base, I18n.t("decidim.verifications.errors.wrong_number_columns", expected: 1, actual: data.count)) if data.count != 1

            errors.add(:base, I18n.t("decidim.verifications.errors.no_emails")) if data.values.empty?

            data.values.each do |value|
              errors.add(:base, t("decidim.verifications.errors.invalid_emails", invalid_emails: value)) unless valid_email?(value)
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
