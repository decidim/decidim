# frozen_string_literal: true

module Decidim
  module TwoFactor
    # The base command of the enrollments: attaches the factor and issues the
    # recovery codes the first time the user needs them.
    class EnrollAuthenticator < Decidim::Command
      # Public: Initializes the command.
      #
      # user - The user attaching the factor.
      def initialize(user)
        @user = user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok with the fresh recovery codes, or nil when the user already holds unused ones.
      # - :invalid if the factor cannot be attached.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid?

        codes = transaction do
          enroll
          generate_recovery_codes
        end

        broadcast(:ok, codes)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      protected

      attr_reader :user

      # Checks run before attaching the factor.
      def invalid? = false

      # Attaches the factor, raising when it cannot be saved.
      def enroll = raise(NotImplementedError)

      private

      def generate_recovery_codes
        return if user.two_factor_recovery_codes.unused.exists?

        RegenerateRecoveryCodes.call(user)[:ok]
      end
    end
  end
end
