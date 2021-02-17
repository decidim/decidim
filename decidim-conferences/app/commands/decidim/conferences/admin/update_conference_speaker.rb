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
          form.avatar = conference_speaker.avatar if form.avatar.blank?
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

          # We are going to assign the attributes only to handle the validation of the avatar before accessing
          # `update_conference_speaker!` which uses `update!`. Without this step, the image validation may render
          # an ActiveRecord::RecordInvalid error
          # After we assign and check if the object is valid, we reload the model to let it be handled the old way
          # If there is an error we add the error to the form
          conference_speaker.assign_attributes(attributes)

          if conference_speaker.valid?
            conference_speaker.reload

            transaction do
              update_conference_speaker!
              link_meetings(@conference_speaker)
            end
            broadcast(:ok)
          else
            form.errors.add(:avatar, conference_speaker.errors[:avatar]) if conference_speaker.errors.include? :avatar

            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :conference_speaker

        def attributes
          form.attributes.slice(
            :full_name,
            :twitter_handle,
            :personal_url,
            :position,
            :affiliation,
            :short_bio
          ).merge(
            user: form.user
          ).merge(uploader_attributes)
        end

        def uploader_attributes
          {
            avatar: form.avatar,
            remove_avatar: form.remove_avatar
          }.delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
        end

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
            attributes,
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
