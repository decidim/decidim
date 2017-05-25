# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class HideResource < Rectify::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      def initialize(reportable)
        @reportable = reportable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the resource.
      # - :invalid if the resource is already hidden
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless hideable?

        hide!
        broadcast(:ok, @reportable)
      end

      private

      def hideable?
        !@reportable.hidden? && @reportable.reported?
      end

      def hide!
        @reportable.moderation.update_attributes!(hidden_at: Time.current)
      end
    end
  end
end
