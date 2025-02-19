# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        # A form to temporarily upload csv census data
        class CensusForm < Form
          # include Decidim::HasUploadValidations

          attribute :email, String

          validates :email, presence: true, "valid_email_2/email": { disposable: true }
          validate :unique_email

          private

          def unique_email
            return true if Decidim::UserBaseEntity.where(
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
