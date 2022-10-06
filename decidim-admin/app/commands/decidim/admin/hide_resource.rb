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

        hide!

        send_hide_notification_to_author

        broadcast(:ok, @reportable)
      end

      private

      def hideable?
        !@reportable.hidden? && @reportable.reported?
      end

      def hide!
        Decidim.traceability.perform_action!(
          "hide",
          @reportable.moderation,
          @current_user,
          extra: {
            reportable_type: @reportable.class.name
          }
        ) do
          @reportable.moderation.update!(hidden_at: Time.current)
          @reportable.try(:touch)
        end
      end

      def send_hide_notification_to_author
        data = {
          event: "decidim.events.reports.resource_hidden",
          event_class: Decidim::ResourceHiddenEvent,
          resource: @reportable,
          extra: {
            report_reasons:
          },
          affected_users: @reportable.try(:authors) || [@reportable.try(:normalized_author)]
        }

        Decidim::EventsManager.publish(**data)
      end

      def report_reasons
        @reportable.moderation.reports.pluck(:reason).uniq
      end
    end
  end
end
