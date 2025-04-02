# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class ProcessCensusDataJob < ApplicationJob
        queue_as :default

        def perform(data, organization)
          data.each do |email|
            if CsvDatum.exists?(email:, organization:)
              Rails.logger.info(I18n.t("census.new_import.errors.email_exists", scope: "decidim.verifications.csv_census.admin", email:, organization: organization.id))
            else
              CsvDatum.create!(organization:, email:)
            end

            authorize_record(email, organization)
          end
        end

        private

        def authorize_record(email, organization)
          user = organization.users.available.find_by(email:)

          unless user
            Rails.logger.info(I18n.t("census.new_import.errors.email_not_found", scope: "decidim.verifications.csv_census.admin", email:, organization: organization.id))
            return
          end

          authorization = Decidim::Authorization.find_or_initialize_by(
            user: user,
            name: "csv_census"
          )

          authorization.grant! unless authorization.granted?
        end
      end
    end
  end
end
