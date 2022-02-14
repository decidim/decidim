# frozen_string_literal: true

module Decidim
  module Admin
    class UnblockUser < Decidim::Command
      # Public: Initializes the command.
      #
      # blocked_user - the user that is unblocked
      # current_user - the user performing the action
      def initialize(blocked_user, current_user)
        @blocked_user = blocked_user
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @blocked_user.blocked?

        unblock!
        broadcast(:ok, @blocked_user)
      end

      private

      def unblock!
        Decidim.traceability.perform_action!(
          "unblock",
          @blocked_user,
          @current_user,
          extra: {
            reportable_type: @blocked_user.class.name
          }
        ) do
          @blocked_user.blocked = false
          @blocked_user.blocked_at = nil
          @blocked_user.block_id = nil
          @blocked_user.name = @blocked_user.user_name
          @blocked_user.save!
        end
      end
    end
  end
end
