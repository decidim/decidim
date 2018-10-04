# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # speaker in the system.
      class CreateConferenceSpeaker < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # conference - The Conference that will hold the speaker
        def initialize(form, current_user, conference)
          @form = form
          @current_user = current_user
          @conference = conference
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_conference_speaker!
            link_meetings(@conference_speaker)
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference, :current_user

        def create_conference_speaker!
          log_info = {
            resource: {
              title: form.full_name
            },
            participatory_space: {
              title: conference.title
            }
          }

          @conference_speaker = Decidim.traceability.create!(
            Decidim::ConferenceSpeaker,
            current_user,
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
              conference: conference,
              user: form.user
            ),
            log_info
          )
        end

        def meetings(conference_speaker)
          meeting_components = conference_speaker.conference.components.where(manifest_name: "meetings")
          @meetings ||= Decidim::Meetings::Meeting.where(component: meeting_components).where(id: @form.attributes[:meeting_ids])
        end

        def link_meetings(conference_speaker)
          conference_speaker.link_participatory_spaces_resources(meetings(conference_speaker), "speaking_meetings")
        end
      end
    end
  end
end
