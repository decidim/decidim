# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class CensusForm < AuthorizationHandler
        attribute :email, String

        validates :email, presence: true
        validate :censed

        def authorized?
          true if census_for_user
        end

        private

        def censed
          return if (email == user.email) && (census_for_user&.email == email)

          if email != user.mail
            errors.add(:email, I18n.t("decidim.verifications.csv_census.errors.messages.not_same_email"))
          else
            errors.add(:email, I18n.t("decidim.verifications.csv_census.errors.messages.not_in_csv"))
          end
        end

        def organization
          current_organization || user&.organization
        end

        def census_for_user
          @census_for_user ||= Decidim::Verifications::CSVCensus::Datum
                               .get_census(organization, email)
        end
      end
    end
  end
end
