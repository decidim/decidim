# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class ProcessCensusDataJob < ApplicationJob
        queue_as :default
        attr_reader :imported_records, :failed, :user

        def perform(data, user)
          @user = user
          @imported_records = []
          @failed = []

          data.each do |email|
            record = CsvDatum.find_or_create_by(email:, organization: user.organization)
            if record && record.valid?
              @imported_records << record
            else
              @failed << email
              Rails.logger.warn(I18n.t("census.new_import.errors.email_exists", scope: "decidim.verifications.csv_census.admin", email:, organization: user.organization.id))
            end

            record.authorize!
          end

          log_import_action
        end

        private

        def log_import_action
          return if imported_records.blank?

          Decidim::ActionLogger.log(
            "import",
            user,
            imported_records.first,
            nil,
            extra: {
              imported_records:,
              failed_count: failed.count
            }
          )
        end
      end
    end
  end
end
