# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class HideResource < Decidim::Command
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
        return broadcast(:invalid) unless hideable?

        with_events do
          tool = Decidim::ModerationTools.new(@reportable, @current_user)
          tool.hide!
          tool.send_notification_to_author
        end

        broadcast(:ok, @reportable)
      end

      private

      def event_arguments
        { resource: @reportable }
      end

      def hideable?
        !@reportable.hidden? && @reportable.reported?
      end
    end
  end
end
