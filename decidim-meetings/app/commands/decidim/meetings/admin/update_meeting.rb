# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Meeting from the admin
      # panel.
      class UpdateMeeting < Decidim::Commands::UpdateResource
        fetch_form_attributes :end_time, :start_time, :online_meeting_url, :registration_type,
                              :registration_url, :registrations_enabled, :address, :latitude, :longitude, :location,
                              :location_hints, :taxonomizations,
                              :private_meeting, :transparent, :iframe_embed_type, :comments_enabled,
                              :comments_start_time, :comments_end_time, :iframe_access_level, :reminder_enabled

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
                        type_of_meeting: form.clean_type_of_meeting,
                        send_reminders_before_hours: form.reminder_enabled ? form.send_reminders_before_hours : nil,
                        reminder_message_custom_content: form.reminder_enabled ? form.reminder_message_custom_content : {}
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
            followers: resource.followers,
            extra: { changed_fields: resource.previous_changes.keys & important_attributes }
          )
        end

        def should_notify_followers?
          resource.published? && important_attributes.any? { |attr| resource.previous_changes[attr].present? }
        end

        def important_attributes
          %w(start_time end_time address location)
        end

        def start_time_changed?
          resource.previous_changes["start_time"].present?
        end

        def address_changed?
          resource.previous_changes["address"].present? || resource.previous_changes["location"].present?
        end

        def schedule_upcoming_meeting_notification
          return if resource.start_time < Time.zone.now
          return unless resource.reminder_enabled

          checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(resource)

          Decidim::Meetings::UpcomingMeetingNotificationJob
            .set(wait_until: resource.start_time - resource.send_reminders_before_hours.hours)
            .perform_later(resource.id, checksum)
        end
      end
    end
  end
end
