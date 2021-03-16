# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      module Admin
        # A form object used to create a datum record (participant) for
        # a voting census
        class DatumForm < Form
          DOCUMENT_TYPES = %w(DNI NIE PASSPORT).freeze

          mimic :datum

          attribute :document_number, String
          attribute :document_type, String
          attribute :birthdate, String
          attribute :full_name, String
          attribute :full_address, String
          attribute :postal_code, String
          attribute :mobile_phone_number, String
          attribute :email, String

          validates :document_number,
                    :document_type,
                    :birthdate,
                    :full_name,
                    :full_address,
                    :postal_code,
                    presence: true

          validates :full_name, format: { with: UserBaseEntity::REGEXP_NAME }

          # validates :email, format: { with: ::Devise.email_regexp }
          validates :document_type, inclusion: { in: DOCUMENT_TYPES }

          # validates :document_number, length: {within: 3..40}, format: { with: /^([a-z0-9\-]+)$/i }
          validate :email_is_unique
          validate :document_number_is_unique

          def email_is_unique
            errors.add(:email, "email is taken") if Datum.exists?(email: email)
          end

          def document_number_is_unique
            errors.add(:document_number, "document_number is taken") if Datum.exists?(document_number: document_number)
          end
        end
      end
    end
  end
end
