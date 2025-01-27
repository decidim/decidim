# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusForm < Form
          attribute :email

          validates :email, presence: true
          validate :unique_email

          private

          def unique_email
            return true if Decidim::User.where(
              organization: context.current_organization,
              email:
            ).where.not(id: context.current_user.id).empty?

            errors.add :email, :taken
            false
          end
        end
      end
    end
  end
end
