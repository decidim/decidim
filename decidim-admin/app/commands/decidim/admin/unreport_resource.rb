# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user unreports a resource.
    class UnreportResource < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user performing the action
      def initialize(reportable, current_user, with_traceability: true)
        @reportable = reportable
        @current_user = current_user
        @with_traceability = with_traceability
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is not reported
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @reportable.reported?

        @with_traceability ? unreport_with_traceability! : unreport!
        broadcast(:ok, @reportable)
      end

      private

      def unreport_with_traceability!
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
        @reportable.moderation.destroy!
      end
    end
  end
end
