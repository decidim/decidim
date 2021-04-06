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
          attribute :ballot_style_code, String

          validates :document_number,
                    :document_type,
                    :birthdate,
                    :full_name,
                    :full_address,
                    :postal_code,
                    presence: true

          validates :document_type, inclusion: { in: DOCUMENT_TYPES }

          # hash of birth, document type and number
          # used by the polling officer to identify a person
          def hashed_in_person_data
            hash_for [document_number, document_type, birthdate]
          end

          # hash of postal code birth, document type and number
          # used by a person to check if present in dataset
          def hashed_check_data
            hash_for [document_number, document_type, birthdate, postal_code]
          end

          def hash_for(data)
            Digest::SHA256.hexdigest(data.join("."))
          end
        end
      end
    end
  end
end
