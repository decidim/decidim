# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class AuthorizeExistingUsersJob < ApplicationJob
        queue_as :default

        def perform(data, current_organization = organization)
          data.each do |email|
            user = current_organization.users.available.find_by(email:)

            return t("census.last_login.no_user", scope: "decidim.verifications.csv_census.admin") unless user

            authorization = Decidim::Authorization.find_or_initialize_by(
              user:,
              name: "csv_census"
            )

            authorization.grant! unless authorization.granted?
          end
        end
      end
    end
  end
end
