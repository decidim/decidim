# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class UnhideResource < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user that performs the action
      def initialize(reportable, current_user)
        @reportable = reportable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is already hidden
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless unhideable?

        unhide!
        broadcast(:ok, @reportable)
      end

      private

      def unhideable?
        @reportable.hidden? && @reportable.reported?
      end

      def unhide!
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
    end
  end
end
