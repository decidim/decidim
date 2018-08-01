# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when updating a conference
      # speaker in the system.
      class UpdateConferenceSpeaker < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference_speaker - The ConferenceSpeaker to update
        def initialize(form, conference_speaker)
          @form = form
          @conference_speaker = conference_speaker
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless conference_speaker

          update_conference_speaker!
          broadcast(:ok)
        end

        private

        attr_reader :form, :conference_speaker

        def update_conference_speaker!
          log_info = {
            resource: {
              title: conference_speaker.full_name
            },
            participatory_space: {
              title: conference_speaker.conference.title
            }
          }

          Decidim.traceability.update!(
            conference_speaker,
            form.current_user,
            form.attributes.slice(
              :full_name,
              :position,
              :affiliation,
              :short_bio,
              :twitter_handle,
              :personal_url,
              :avatar,
              :remove_avatar
            ).merge(
              user: form.user
            ),
            log_info
          )
        end
      end
    end
  end
end
