# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when destroying an conference
      # speaker in the system.
      class DestroyConferenceSpeaker < Rectify::Command
        # Public: Initializes the command.
        #
        # conference_speaker - the ConferenceSpeaker to destroy
        # current_user - the user performing this action
        def initialize(conference_speaker, current_user)
          @conference_speaker = conference_speaker
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          destroy_speaker!
          broadcast(:ok)
        end

        private

        attr_reader :conference_speaker, :current_user

        def destroy_speaker!
          log_info = {
            resource: {
              title: conference_speaker.full_name
            },
            participatory_space: {
              title: conference_speaker.conference.title
            }
          }

          Decidim.traceability.perform_action!(
            "delete",
            conference_speaker,
            current_user,
            log_info
          ) do
            conference_speaker.destroy!
            conference_speaker
          end
        end
      end
    end
  end
end
