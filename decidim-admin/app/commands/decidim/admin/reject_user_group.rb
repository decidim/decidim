# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when rejecting a user_group.
    class RejectUserGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # user_group - The user_group to reject
      # current_user - The user performing the action
      def initialize(user_group, current_user)
        @user_group = user_group
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @user_group.valid?

        reject_user_group
        broadcast(:ok)
      end

      private

      def reject_user_group
        Decidim.traceability.perform_action!(
          "reject",
          @user_group,
          @current_user
        ) do
          @user_group.reject!
        end
      end
    end
  end
end
