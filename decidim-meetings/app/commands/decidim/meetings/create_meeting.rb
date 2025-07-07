# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when a participant creates a Meeting from the public
    # views.
    class CreateMeeting < Decidim::Commands::CreateResource
      fetch_form_attributes :end_time, :start_time, :address, :latitude, :longitude,
                            :online_meeting_url, :registration_type, :registration_url, :available_slots,
                            :registrations_enabled, :taxonomizations, :component, :iframe_embed_type, :iframe_access_level

      protected

      def create_resource
        with_events(with_transaction: true) do
          super

          Decidim.traceability.perform_action!(:publish, resource, form.current_user, visibility: "all") do
            resource.publish!
          end
        end
      end

      def run_after_hooks
        create_follow_form_resource(form.current_user)
        schedule_upcoming_meeting_notification
        send_notification
      end

      def event_arguments
        {
          resource:,
          extra: {
            event_author: form.current_user,
            locale:
          }
        }
      end

      def resource_class = Decidim::Meetings::Meeting

      def attributes
        parsed_title = Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite

        super.merge({
                      title: { I18n.locale => parsed_title },
                      description: { I18n.locale => parsed_description },
                      location: { I18n.locale => form.location },
                      location_hints: { I18n.locale => form.location_hints },
                      author: form.current_user,
                      registration_terms: { I18n.locale => form.registration_terms },
                      type_of_meeting: form.clean_type_of_meeting,
                      published_at: Time.current
                    })
      end

      def extra_params = { visibility: "public-only" }

      def schedule_upcoming_meeting_notification
        return if resource.start_time < Time.zone.now

        checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(resource)

        Decidim::Meetings::UpcomingMeetingNotificationJob
          .set(wait_until: resource.start_time - Decidim::Meetings.upcoming_meeting_notification)
          .perform_later(resource.id, checksum)
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_created",
          event_class: Decidim::Meetings::CreateMeetingEvent,
          resource:,
          followers: resource.participatory_space.followers
        )
      end

      def create_follow_form_resource(user)
        follow_form = Decidim::FollowForm.from_params(followable_gid: resource.to_signed_global_id.to_s).with_context(current_user: user)
        Decidim::CreateFollow.call(follow_form)
      end
    end
  end
end
