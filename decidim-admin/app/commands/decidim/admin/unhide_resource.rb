# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class UnhideResource < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user that performs the action
      def initialize(reportable, current_user, with_traceability: true)
        @reportable = reportable
        @current_user = current_user
        @with_traceability = with_traceability
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is already hidden
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless unhideable?

        with_traceability ? unhide_with_traceability! : unhide!
        broadcast(:ok, @reportable)
      end

      private

      def unhideable?
        @reportable.hidden? && @reportable.reported?
      end

      def unhide_with_traceability!
        Decidim.traceability.perform_action!(
          "unhide",
          @reportable.moderation,
          @current_user,
          extra: {
            reportable_type: @reportable.class.name
          }
        ) do
          @reportable.moderation.update!(hidden_at: nil)
        end
      end

      def unhide!
        @reportable.moderation.update!(hidden_at: nil)
      end
    end
  end
end
