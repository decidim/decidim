# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      class CensusForm < AuthorizationHandler
        attribute :email, String

        validates :email, presence: true, 'valid_email_2/email': { disposable: true }
        validate :censed

        def authorized?
          true if census_for_user
        end

        private

        def censed
          return if (email == current_user.email) && (census_for_user&.email == email)

          if email != current_user.email
            errors.add(:email, I18n.t("decidim.verifications.csv_census.errors.messages.not_same_email"))
          else
            errors.add(:email, I18n.t("decidim.verifications.csv_census.errors.messages.not_in_csv"))
          end
        end

        def organization
          current_organization || current_user.organization
        end

        def census_for_user
          @census_for_user ||= CsvDatum
                               .search_user_email(organization, email)
        end
      end
    end
  end
end
