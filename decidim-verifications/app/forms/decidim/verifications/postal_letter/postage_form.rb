# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      # A form object to be used when admins want to mark a verification letter
      # as sent.
      class PostageForm < AuthorizationHandler
        attribute :full_address, String
        attribute :verification_code, String

        validates :full_address, presence: true
        validates :verification_code, presence: true

        def handler_name
          "postal_letter"
        end

        def map_model(model)
          self.verification_code = model.verification_metadata["pending_verification_code"]
          self.full_address = model.verification_metadata["address"]
        end

        def verification_metadata
          {
            address: full_address,
            verification_code:,
            letter_sent_at: Time.current
          }
        end
      end
    end
  end
end
