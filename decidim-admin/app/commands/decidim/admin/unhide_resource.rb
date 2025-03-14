# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class UnhideResource < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user that performs the action
      # with_admin_log Boolean - determines whether to log the action of unhide a resource in the admin log
      def initialize(reportable, current_user, with_admin_log: true)
        @reportable = reportable
        @current_user = current_user
        @with_admin_log = with_admin_log
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is already hidden
      #
      # Returns nothing.
      def call
        return broadcast(:parent_invalid) if @reportable.respond_to?(:commentable) && @reportable.commentable.try(:hidden?)
        return broadcast(:invalid) unless unhideable?

        @with_admin_log ? unhide_with_admin_log! : unhide!
        broadcast(:ok, @reportable)
      end

      private

      def unhideable?
        @reportable.hidden? && @reportable.reported?
      end

      def unhide_with_admin_log!
        Decidim.traceability.perform_action!(
          "unhide",
          @reportable.moderation,
          @current_user,
          extra: {
            reportable_type: @reportable.class.name
          }
        ) do
          unhide!
        end
      end

      def unhide!
        Decidim.traceability.perform_action_without_log!(@current_user) do
          @reportable.moderation.update!(hidden_at: nil)
        end
      end
    end
  end
end
