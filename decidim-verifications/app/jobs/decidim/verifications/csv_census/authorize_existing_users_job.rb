# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class AuthorizeExistingUsersJob < ApplicationJob
        def perform(data)
          user = current_organization.users.available.find_by(email: data.email)

          return t(".no_user") unless user

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
