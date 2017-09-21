# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when rejecting a user_group.
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
        @user_group.update_attributes!(rejected_at: Time.current, verified_at: nil)
      end
    end
  end
end
