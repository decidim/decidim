# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user unreports a resource.
    class UnreportResource < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user performing the action
      # with_admin_log Boolean - determines whether to log the action of unreport a resource in the admin log
      def initialize(reportable, current_user, with_admin_log: true)
        @reportable = reportable
        @current_user = current_user
        @with_admin_log = with_admin_log
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @reportable.reported?

        @with_admin_log ? unreport_with_admin_log! : unreport!
        broadcast(:ok, @reportable)
      end

      private

      def unreport_with_admin_log!
        Decidim.traceability.perform_action!(
          "unreport",
          @reportable.moderation,
          @current_user,
          extra: {
            reportable_type: @reportable.class.name
          }
        ) do
          unreport!
        end
      end

      def unreport!
        Decidim.traceability.perform_action_without_log!(@current_user) do
          @reportable.moderation.destroy!
        end
      end
    end
  end
end
