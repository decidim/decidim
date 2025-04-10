# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusForm < Form
          attribute :email

          validates :email, presence: true, "valid_email_2/email": { disposable: true }
          validate :unique_email

          private

          def unique_email
            return true if CsvDatum.where(
              organization: context.current_organization,
              email:
            ).empty?

            errors.add :email, :taken
            false
          end
        end
      end
    end
  end
end
