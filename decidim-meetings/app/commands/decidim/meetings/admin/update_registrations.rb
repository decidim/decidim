# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user updates the meeting registrations.
      class UpdateRegistrations < Decidim::Commands::UpdateResource
        fetch_form_attributes :registrations_enabled, :registration_form_enabled

        def run_after_hooks
          if resource.previous_changes["registrations_enabled"].present? && resource.registrations_enabled?
            Decidim::EventsManager.publish(
              event: "decidim.events.meetings.registrations_enabled",
              event_class: Decidim::Meetings::MeetingRegistrationsEnabledEvent,
              resource:,
              followers: resource.followers
            )
          end

          promote_from_waitlist!
        end

        protected

        def attributes
          extra_params = {}
          if form.registrations_enabled
            extra_params = {
              available_slots: form.available_slots,
              reserved_slots: form.reserved_slots,
              registration_terms: form.registration_terms,
              customize_registration_email: form.customize_registration_email
            }
            extra_params.merge!(registration_email_custom_content: form.registration_email_custom_content) if form.customize_registration_email
          end
          super.merge(extra_params)
        end

        def promote_from_waitlist!
          slot_changes = resource.previous_changes.keys & %w(available_slots reserved_slots)
          return if slot_changes.empty?
          return if resource.available_slots.zero?
          return unless resource.remaining_slots.positive?
          return unless resource.registrations.on_waiting_list.exists?

          Decidim::Meetings::PromoteFromWaitlistJob.perform_later(resource.id)
        end
      end
    end
  end
end
