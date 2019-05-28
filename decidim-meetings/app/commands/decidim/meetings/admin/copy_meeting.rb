# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic when copying a meeting
      # in the system.
      class CopyMeeting < Rectify::Command
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
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            copy_meeting!
            schedule_upcoming_meeting_notification
            send_notification
          end

          broadcast(:ok, @copied_meeting)
        end

        private

        attr_reader :form, :meeting

        def copy_meeting!
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, @form.title, current_organization: @meeting.organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, @form.description, current_organization: @meeting.organization).rewrite

          @copied_meeting = Decidim.traceability.create!(
            Meeting,
            @form.current_user,
            scope: @meeting.scope,
            category: @meeting.category,
            title: parsed_title,
            description: parsed_description,
            end_time: @form.end_time,
            start_time: @form.start_time,
            address: @form.address,
            latitude: @form.latitude,
            longitude: @form.longitude,
            location: @form.location,
            location_hints: @form.location_hints,
            services: @form.services_to_persist.map { |service| { "title" => service.title, "description" => service.description } },
            component: @meeting.component,
            private_meeting: @form.private_meeting,
            transparent: @form.transparent,
            organizer: @form.organizer,
            questionnaire: @form.questionnaire,
            registrations_enabled: @meeting.registrations_enabled,
            available_slots: @meeting.available_slots,
            registration_terms: @meeting.registration_terms
          )
        end

        def schedule_upcoming_meeting_notification
          checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(@copied_meeting)

          Decidim::Meetings::UpcomingMeetingNotificationJob
            .set(wait_until: @copied_meeting.start_time - 2.days)
            .perform_later(@copied_meeting.id, checksum)
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_created",
            event_class: Decidim::Meetings::CreateMeetingEvent,
            resource: @copied_meeting,
            followers: @copied_meeting.participatory_space.followers
          )
        end
      end
    end
  end
end
