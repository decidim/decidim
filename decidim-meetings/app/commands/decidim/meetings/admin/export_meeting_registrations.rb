# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user exports the registrations of
      # a Meeting from the admin panel.
      class ExportMeetingRegistrations < Decidim::Command
        # meeting - The current instance of the page to be closed.
        # format - a string representing the export format
        # current_user - the user performing the action
        def initialize(meeting, format, current_user)
          @meeting = meeting
          @format = format
          @current_user = current_user
        end

        # Exports the meeting registrations.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          broadcast(:ok, export_data)
        end

        private

        attr_reader :current_user, :meeting, :format

        def export_data
          Decidim.traceability.perform_action!(
            :export_registrations,
            meeting,
            current_user
          ) do
            Decidim::Exporters
              .find_exporter(format)
              .new(meeting.registrations, Decidim::Meetings::RegistrationSerializer)
              .export
          end
        end
      end
    end
  end
end
