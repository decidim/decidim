# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when verifying a user_group.
    class VerifyUserGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # user_group - The user_group to verify
      # current_user - the user performing the action
      def initialize(user_group, current_user, via_csv: false)
        @user_group = user_group
        @current_user = current_user
        @via_csv = via_csv
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @user_group.valid?

        verify_user_group
        broadcast(:ok)
      end

      private

      def verify_user_group
        action = @via_csv ? "verify_via_csv" : "verify"
        Decidim.traceability.perform_action!(
          action,
          @user_group,
          @current_user
        ) do
          @user_group.verify!
        end
      end
    end
  end
end
