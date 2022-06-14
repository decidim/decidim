# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when a participant or user group creates a Meeting from the public
    # views.
    class CreateMeeting < Rectify::Command
      def initialize(form)
        @form = form
      end

      # Creates the meeting if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_meeting!
          schedule_upcoming_meeting_notification
          send_notification
        end

        create_follow_form_resource(form.current_user)
        broadcast(:ok, meeting)
      end

      private

      attr_reader :meeting, :form

      def create_meeting!
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite

        params = {
          scope: form.scope,
          category: form.category,
          title: { I18n.locale => parsed_title },
          description: { I18n.locale => parsed_description },
          end_time: form.end_time,
          start_time: form.start_time,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude,
          location: { I18n.locale => form.location },
          location_hints: { I18n.locale => form.location_hints },
          author: form.current_user,
          decidim_user_group_id: form.user_group_id,
          online_meeting_url: form.online_meeting_url,
          registration_type: form.registration_type,
          registration_url: form.registration_url,
          available_slots: form.available_slots,
          registration_terms: { I18n.locale => form.registration_terms },
          registrations_enabled: form.registrations_enabled,
          type_of_meeting: form.clean_type_of_meeting,
          component: form.current_component,
          published_at: Time.current,
          iframe_embed_type: form.iframe_embed_type,
          iframe_access_level: form.iframe_access_level
        }

        @meeting = Decidim.traceability.create!(
          Meeting,
          form.current_user,
          params,
          visibility: "public-only"
        )
        Decidim.traceability.perform_action!(:publish, meeting, form.current_user, visibility: "all") do
          meeting.publish!
        end
      end

      def schedule_upcoming_meeting_notification
        return if meeting.start_time < Time.zone.now

        checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(meeting)

        Decidim::Meetings::UpcomingMeetingNotificationJob
          .set(wait_until: meeting.start_time - Decidim::Meetings.upcoming_meeting_notification)
          .perform_later(meeting.id, checksum)
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_created",
          event_class: Decidim::Meetings::CreateMeetingEvent,
          resource: meeting,
          followers: meeting.participatory_space.followers
        )
      end

      def create_follow_form_resource(user)
        follow_form = Decidim::FollowForm.from_params(followable_gid: meeting.to_signed_global_id.to_s).with_context(current_user: user)
        Decidim::CreateFollow.call(follow_form, user)
      end
    end
  end
end
