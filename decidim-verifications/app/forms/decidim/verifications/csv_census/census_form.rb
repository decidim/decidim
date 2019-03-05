# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class CensusForm < AuthorizationHandler
        validate :censed

        def authorized?
          true if census_for_user
        end

        private

        def censed
          return if census_for_user&.email == user.email

          errors.add(:email, I18n.t("decidim.verifications.csv_census.authorizations.new.error"))
        end

        def organization
          current_organization || user.organization
        end

        def census_for_user
          @census_for_user ||= CsvDatum
                               .search_user_email(organization, user.email)
        end
      end
    end
  end
end
