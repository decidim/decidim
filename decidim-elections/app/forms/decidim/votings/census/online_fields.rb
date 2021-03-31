# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Census
      # Definition of the fields required to be used on Datum forms for online voting
      module OnlineFields
        extend ActiveSupport::Concern

        included do
          include Decidim::Votings::Census::CheckFields

          attribute :access_code, String

          validates :access_code,
                    presence: true
        end

        # hash of access code, postal code, birth, document type and number
        # used by a voter to identify before online voting
        def hashed_online_data
          hash_for [document_number, document_type, birthdate, postal_code, access_code]
        end
      end
    end
  end
end
