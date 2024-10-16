# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Meeting from the admin
      # panel.
      class UpdateMeeting < Decidim::Commands::UpdateResource
        fetch_form_attributes :scope, :category, :end_time, :start_time, :online_meeting_url, :registration_type,
                              :registration_url, :registrations_enabled, :address, :latitude, :longitude, :location,
                              :location_hints,
                              :private_meeting, :transparent, :iframe_embed_type, :comments_enabled,
                              :comments_start_time, :comments_end_time, :iframe_access_level

        protected

        def run_after_hooks
          send_notification if should_notify_followers?
          schedule_upcoming_meeting_notification if resource.published? && start_time_changed?
          update_services!
          update_components!
        end

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite
          super.merge({
                        title: parsed_title,
                        description: parsed_description,
                        type_of_meeting: form.clean_type_of_meeting
                      })
        end

        def update_services!
          resource.services = form.services_to_persist.map do |service|
            Decidim::Meetings::Service.new(title: service.title, description: service.description)
          end
          resource.save!
        end

        def update_components!
          resource.components = form.components
          resource.save!
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_updated",
            event_class: Decidim::Meetings::UpdateMeetingEvent,
            resource:,
            followers: resource.followers
          )
        end

        def should_notify_followers?
          resource.published? && important_attributes.any? { |attr| resource.previous_changes[attr].present? }
        end

        def important_attributes
          %w(start_time end_time address)
        end

        def start_time_changed?
          resource.previous_changes["start_time"].present?
        end

        def schedule_upcoming_meeting_notification
          return if resource.start_time < Time.zone.now

          checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(resource)

          Decidim::Meetings::UpcomingMeetingNotificationJob
            .set(wait_until: resource.start_time - Decidim::Meetings.upcoming_meeting_notification)
            .perform_later(resource.id, checksum)
        end
      end
    end
  end
end
