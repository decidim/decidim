# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      module Censuses
        class InternalUsersForm < Decidim::Form
          attribute :verification_handlers, Array[String]

          validate :verification_is_valid

          # Returns the settings that need to be persisted in the census.
          def census_settings
            {
              verification_handlers: verification_handlers
            }
          end

          private

          def verification_is_valid
            return if verification_handlers.blank?

            valid_types = context.current_organization.available_authorizations
            invalid_types = (verification_handlers - valid_types).compact_blank

            errors.add(:verification_handlers, :invalid, types: invalid_types.join(", ")) if invalid_types.present?
          end
        end
      end
    end
  end
end
