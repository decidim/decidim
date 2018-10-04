# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when verifying a user_group.
    class VerifyUserGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # user_group - The user_group to verify
      # current_user - the user performing the action
      def initialize(user_group, current_user)
        @user_group = user_group
        @current_user = current_user
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
        Decidim.traceability.perform_action!(
          "verify",
          @user_group,
          @current_user
        ) do
          @user_group.verify!
        end
      end
    end
  end
end
