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
            link_meetings
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :conference, :current_user, :conference_speaker

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

        def meetings
          @meetings ||= conference_speaker.participatory_space_sibling_scope(:conferences).where(id: @form.meeting_ids)
        end

        def link_meetings
          conference_speaker.link_participatory_spaces_resources(meetings, "speaking_meetings")
        end
      end
    end
  end
end
