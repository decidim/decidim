# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      # A form object that just holds a verification code that the user will
      # have received by postal letter.
      class ConfirmationForm < AuthorizationHandler
        attribute :verification_code, String

        validates :verification_code, presence: true

        def verification_metadata
          { "verification_code" => verification_code }
        end
      end
    end
  end
end
