# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This command is executed when the user exports the registrations of
      # a Conference from the admin panel.
      class ExportConferenceRegistrations < Decidim::Command
        # conference - The current instance of the page to be closed.
        # format - a string representing the export format
        # current_user - the user performing the action
        def initialize(conference, format, current_user)
          @conference = conference
          @format = format
          @current_user = current_user
        end

        # Exports the conference registrations.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          broadcast(:ok, export_data)
        end

        private

        attr_reader :current_user, :conference, :format

        def export_data
          Decidim.traceability.perform_action!(
            :export_conference_registrations,
            conference,
            current_user
          ) do
            Decidim::Exporters
              .find_exporter(format)
              .new(conference.conference_registrations, Decidim::Conferences::ConferenceRegistrationSerializer)
              .export
          end
        end
      end
    end
  end
end
