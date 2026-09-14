# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Detaches a second factor; the recovery codes go with the last one.
    class RemoveAuthenticator < Decidim::Command
      delegate :user, to: :authenticator

      # Public: Initializes the command.
      #
      # authenticator - The authenticator to detach.
      def initialize(authenticator)
        @authenticator = authenticator
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when the factor was removed.
      # - :invalid if there is no such factor.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if authenticator.blank?

        transaction do
          authenticator.destroy!
          user.two_factor_recovery_codes.destroy_all unless user.two_factor_enabled?
        end

        broadcast(:ok)
      end

      private

      attr_reader :authenticator
    end
  end
end
