# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic when a user hides a resource.
    class HideResource < Decidim::Command
      # Public: Initializes the command.
      #
      # reportable - A Decidim::Reportable
      # current_user - the user that performs the action
      # with_admin_log Boolean - determines whether to log the action of hiding a resource in the admin log
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
        return broadcast(:invalid) unless hideable?

        with_events do
          tool = Decidim::ModerationTools.new(@reportable, @current_user)
          @with_admin_log ? tool.hide_with_admin_log! : tool.hide!
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
