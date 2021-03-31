# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Census
      # Definition of the fields required to be used on Datum forms for identity checking
      module CheckFields
        extend ActiveSupport::Concern

        included do
          include Decidim::Votings::Census::InPersonFields

          attribute :postal_code, String

          validates :postal_code,
                    presence: true
        end

        # hash of postal code, birth, document type and number
        # used by a person to check if present in dataset
        def hashed_check_data
          hash_for [document_number, document_type, birthdate, postal_code]
        end
      end
    end
  end
end
