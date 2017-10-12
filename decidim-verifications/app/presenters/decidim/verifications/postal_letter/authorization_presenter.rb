# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      class AuthorizationPresenter < SimpleDelegator
        def self.for_collection(authorizations)
          authorizations.map { |authorization| new(authorization) }
        end

        def verification_address
          verification_metadata["address"]
        end

        def verification_code
          if letter_sent?
            verification_metadata["verification_code"]
          else
            verification_metadata["pending_verification_code"]
          end
        end

        def letter_sent?
          verification_metadata["verification_code"].present?
        end
      end
    end
  end
end
