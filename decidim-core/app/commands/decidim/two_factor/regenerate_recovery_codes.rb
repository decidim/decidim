# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Replaces the recovery codes of a user with a fresh set.
    class RegenerateRecoveryCodes < Decidim::Command
      # Public: Initializes the command.
      #
      # user - The user whose recovery codes are replaced.
      def initialize(user)
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok with the new codes in plain form.
      #
      # Returns nothing.
      def call
        # The row lock serialises two regenerations, so a single set stays valid.
        codes = user.with_lock do
          user.two_factor_recovery_codes.destroy_all
          Array.new(Decidim.two_factor_recovery_codes_count) { create_code }
        end

        broadcast(:ok, codes)
      end

      private

      attr_reader :user

      def create_code
        plain = SecureRandom.hex(16)
        user.two_factor_recovery_codes.create!(code_digest: CodeDigest.create(plain))
        plain
      end
    end
  end
end
