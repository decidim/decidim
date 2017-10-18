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
