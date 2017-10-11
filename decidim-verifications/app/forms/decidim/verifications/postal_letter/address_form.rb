# frozen_string_literal: true

require "securerandom"

module Decidim
  module Verifications
    module PostalLetter
      # A form object to be used when public users want to get verified by
      # uploading their identity documents.
      class AddressForm < AuthorizationHandler
        attribute :full_address, String

        validates :full_address, presence: true

        def handler_name
          "postal_letter"
        end

        def verification_metadata
          {
            address: full_address,
            pending_verification_code: SecureRandom.random_number(1_000_000).to_s
          }
        end
      end
    end
  end
end
