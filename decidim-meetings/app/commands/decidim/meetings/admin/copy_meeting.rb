# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic when copying a meeting
      # in the system.
      class CopyMeeting < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # meeting - A meeting we want to duplicate
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            copy_meeting!
            copy_services!
            send_notification
          end

          broadcast(:ok, copied_meeting)
        end

        private

        attr_reader :form, :meeting, :copied_meeting

        def copy_meeting!
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: meeting.organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: meeting.organization).rewrite

          @copied_meeting = Decidim.traceability.create!(
            Meeting,
            form.current_user,
            scope: form.scope,
            category: form.category,
            title: parsed_title,
            description: parsed_description,
            end_time: form.end_time,
            start_time: form.start_time,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints,
            component: meeting.component,
            private_meeting: form.private_meeting,
            transparent: form.transparent,
            author: form.current_organization,
            questionnaire: form.questionnaire,
            online_meeting_url: form.online_meeting_url,
            type_of_meeting: form.type_of_meeting,
            iframe_embed_type: form.iframe_embed_type,
            iframe_access_level: form.iframe_access_level,
            comments_enabled: form.comments_enabled,
            comments_start_time: form.comments_start_time,
            comments_end_time: form.comments_end_time,
            registration_type: form.registration_type,
            registration_url: form.registration_url,
            **fields_from_meeting
          )
        end

        def fields_from_meeting
          {
            registrations_enabled: meeting.registrations_enabled,
            available_slots: meeting.available_slots,
            registration_terms: meeting.registration_terms,
            reserved_slots: meeting.reserved_slots,
            customize_registration_email: meeting.customize_registration_email,
            registration_form_enabled: meeting.registration_form_enabled,
            registration_email_custom_content: meeting.registration_email_custom_content
          }
        end

        def copy_services!
          form.services_to_persist.map do |service|
            Decidim::Meetings::Service.create!(
              meeting: copied_meeting,
              "title" => service.title,
              "description" => service.description
            )
          end
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_created",
            event_class: Decidim::Meetings::CreateMeetingEvent,
            resource: copied_meeting,
            followers: copied_meeting.participatory_space.followers
          )
        end
      end
    end
  end
end
