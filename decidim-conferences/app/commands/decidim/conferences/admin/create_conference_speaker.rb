# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # speaker in the system.
      class CreateConferenceSpeaker < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

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

          # We are going to assign the attributes only to handle the validation of the avatar before accessing
          # `create_conference_speaker!` which uses `create!`, and this will render an ActiveRecord::RecordInvalid error
          # After we assign and check if the object is valid, we will not save the model to let it be handled the old way
          # If there is an error we add the error to the form
          # We are using this method to assign the conference because if we are trying to assign all at once, there will be thrown a
          # Delegation error

          if conference_speaker_with_attributes.valid?

            transaction do
              create_conference_speaker!
              link_meetings(@conference_speaker)
            end
            broadcast(:ok)
          else
            form.errors.add(:avatar, conference_speaker_with_attributes.errors[:avatar]) if conference_speaker_with_attributes.errors.include? :avatar

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference, :current_user

        def conference_speaker_attributes
          @conference_speaker_attributes ||= form.attributes.slice(
            "full_name",
            "twitter_handle",
            "personal_url",
            "position",
            "affiliation",
            "short_bio"
          ).symbolize_keys.merge(
            decidim_conference_id: conference.id,
            conference:,
            user: form.user
          ).merge(
            attachment_attributes(:avatar)
          )
        end

        def conference_speaker_with_attributes
          conference_speaker = conference.speakers.build
          conference_speaker.conference = conference
          conference_speaker.assign_attributes(conference_speaker_attributes)
          conference_speaker
        end

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
            conference_speaker_attributes,
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
