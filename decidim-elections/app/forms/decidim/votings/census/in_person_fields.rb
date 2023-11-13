# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Census
      # Definition of the fields required to be used on Datum forms for in person voting
      module InPersonFields
        extend ActiveSupport::Concern

        included do
          attribute :document_number, String
          attribute :document_type, String
          attribute :birthdate, String

          validates :document_number,
                    :document_type,
                    :birthdate,
                    presence: true

          validates :document_type, inclusion: { in: :document_types }
        end

        # hash of birth, document type and number
        # used by the polling officer to identify a person
        def hashed_in_person_data
          hash_for document_number, document_type, birthdate
        end

        def hash_for(*data)
          Digest::SHA256.hexdigest(data.join("."))
        end

        def options_for_document_type_select
          document_types.map do |document_type|
            [
              I18n.t(document_type.downcase, scope: "decidim.votings.census.document_types"),
              document_type
            ]
          end
        end

        private

        def document_types
          Decidim::Elections.document_types
        end
      end
    end
  end
end
