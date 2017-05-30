# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when updating a user_group.
    class RejectUserGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # user_group - The user_group to reject
      def initialize(user_group)
        @user_group = user_group
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        verify_user_group
        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid
        broadcast(:invalid)
      end

      private

      def verify_user_group
        @user_group.update_attributes!(rejected_at: Time.current, verified_at: nil)
      end
    end
  end
end
