# frozen_string_literal: true

require "rotp"

module Decidim
  module TwoFactor
    # Time-based one-time codes (RFC 6238); each code is accepted at most once.
    class TotpAuthenticator < Authenticator
      include Decidim::TranslatableAttributes

      validates :secret, presence: true

      # Starts the enrollment with a fresh secret; nil once the app is confirmed.
      def self.issue_for(user)
        authenticator = find_or_initialize_by(user:)
        return if authenticator.confirmed?

        authenticator.update!(secret: ROTP::Base32.random)
        authenticator
      end

      def verify(form, _challenge = nil)
        return false if form.code.blank? || secret.blank?

        matched_timestep = ROTP::TOTP.new(secret).verify(
          form.code,
          drift_behind: Decidim.two_factor_totp_drift,
          drift_ahead: Decidim.two_factor_totp_drift,
          after: last_used_timestep
        )
        return false unless matched_timestep

        # Conditional on the timestep read above: two concurrent submissions cannot both spend the code.
        # rubocop:disable-next Rails/SkipsModelValidations
        used = self.class.where(id:, last_used_timestep:).update_all(last_used_timestep: matched_timestep) == 1
        reload if used

        used
      end

      def provisioning_uri
        ROTP::TOTP.new(secret, issuer: translated_attribute(user.organization.name)).provisioning_uri(user.email)
      end
    end
  end
end
