# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic that unpublishes an
      # existing conference speaker.
      class UnpublishConferenceSpeaker < Decidim::Command
        # Public: Initializes the command.
        #
        # conference_speaker - Decidim::Conferences::Admin::ConferenceSpeaker
        # current_user - the user performing the action
        def initialize(conference_speaker, current_user)
          @conference_speaker = conference_speaker
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless conference_speaker.published?

          @conference_speaker = Decidim.traceability.perform_action!(
            :unpublish,
            conference_speaker,
            current_user
          ) do
            conference_speaker.unpublish!
            conference_speaker
          end
          broadcast(:ok, conference_speaker)
        end

        private

        attr_reader :conference_speaker, :current_user
      end
    end
  end
end
