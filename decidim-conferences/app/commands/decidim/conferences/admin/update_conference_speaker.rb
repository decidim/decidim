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

          transaction do
            update_conference_speaker!
            link_meetings(@conference_speaker)
          end

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

        def conference_meetings(speaker)
          meeting_components = speaker.conference.components.where(manifest_name: "meetings")
          Decidim::ConferenceMeeting.where(component: meeting_components).where(id: @form.attributes[:conference_meeting_ids])
        end

        def link_meetings(conference_speaker)
          conference_speaker.conference_meetings = conference_meetings(conference_speaker)
        end
      end
    end
  end
end
