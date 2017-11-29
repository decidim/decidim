# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      #
      # Decorator for postal letter authorizations.
      #
      class AuthorizationPresenter < SimpleDelegator
        def self.for_collection(authorizations)
          authorizations.map { |authorization| new(authorization) }
        end

        #
        # The address where the verification code will be sent
        #
        def verification_address
          verification_metadata["address"]
        end

        #
        # The verification code to be sent. It's kept in a different metadata
        # key according to whether it has already been sent or not
        #
        def verification_code
          if letter_sent?
            verification_metadata["verification_code"]
          else
            verification_metadata["pending_verification_code"]
          end
        end

        #
        # Whether the letter with the verification code has already been sent or
        # not
        #
        def letter_sent?
          verification_metadata["verification_code"].present?
        end

        #
        # Formatted time when the postal letter was sent. Or an informational
        # string if not yet sent
        #
        def letter_sent_at
          unless letter_sent?
            return I18n.t("pending_authorizations.index.not_yet_sent",
                          scope: "decidim.verifications.postal_letter.admin")
          end

          I18n.l(
            Time.zone.parse(verification_metadata["letter_sent_at"]),
            format: :short
          )
        end
      end
    end
  end
end
