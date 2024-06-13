# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic that publishes an
      # existing conference speakers.
      class PublishConferenceSpeaker < Decidim::Command
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
          return broadcast(:invalid) if conference_speaker.published?

          transaction do
            publish_conference_speaker
          end

          broadcast(:ok, conference_speaker)
        end

        private

        attr_reader :conference_speaker, :current_user

        def publish_conference_speaker
          @conference_speaker = Decidim.traceability.perform_action!(
            :publish,
            conference_speaker,
            current_user
          ) do
            conference_speaker.publish!
            conference_speaker
          end
        end
      end
    end
  end
end
