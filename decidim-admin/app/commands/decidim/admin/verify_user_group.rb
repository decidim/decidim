# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when verifying a user_group.
    class VerifyUserGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # user_group - The user_group to verify
      def initialize(user_group)
        @user_group = user_group
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
        @user_group.update_attributes!(verified_at: Time.current, rejected_at: nil)
      end
    end
  end
end
