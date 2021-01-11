# frozen_string_literal: true

module Decidim
  module Admin
    class UnsuspendUser < Rectify::Command
      # Public: Initializes the command.
      #
      # suspendable - the user that is unblocked
      # current_user - the user performing the action
      def initialize(suspendable, current_user)
        @suspendable = suspendable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @suspendable.suspended?

        unsuspend!
        broadcast(:ok, @suspendable)
      end

      private

      def unsuspend!
        Decidim.traceability.perform_action!(
          "unsuspend",
          @suspendable,
          @current_user,
          extra: {
            reportable_type: @suspendable.class.name
          }
        ) do
          @suspendable.suspended = false
          @suspendable.suspended_at = nil
          @suspendable.suspension_id = nil
          @suspendable.name = @suspendable.user_name
          @suspendable.save!
        end
      end
    end
  end
end
