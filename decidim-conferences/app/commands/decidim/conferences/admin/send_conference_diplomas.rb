# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic to send diplomas to registered conference users.
      #
      class SendConferenceDiplomas < Decidim::Command
        # Public: Initializes the command.
        #
        # conference      - The conference which the user is invited to.
        def initialize(conference, current_user)
          @conference = conference
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if conference.diploma_sent?

          send_diplomas
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :conference

        def send_diplomas
          Decidim.traceability.perform_action!(
            :send_conference_diplomas,
            conference,
            current_user
          ) do
            SendConferenceDiplomaJob.perform_later(conference)
            conference.diploma_sent_at = Time.current
            conference.save!
          end
        end
      end
    end
  end
end
