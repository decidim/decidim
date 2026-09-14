# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Removes every second factor from an account so the owner signs in with
    # the password alone again.
    class ResetUser < Decidim::Command
      # Public: Initializes the command.
      #
      # user - The user losing all the second factors.
      def initialize(user)
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when every factor was removed.
      # - :invalid if the account has no second factor to remove.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless user.two_factor_authenticators.exists?

        transaction do
          user.two_factor_authenticators.destroy_all
          user.two_factor_recovery_codes.destroy_all
        end

        TwoFactorMailer.factors_reset(user).deliver_later

        broadcast(:ok)
      end

      private

      attr_reader :user
    end
  end
end
