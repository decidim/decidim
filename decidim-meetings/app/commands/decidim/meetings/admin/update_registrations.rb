# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user updates the meeting registrations.
      class UpdateRegistrations < Decidim::Commands::UpdateResource
        fetch_form_attributes :registrations_enabled, :registration_form_enabled

        def run_after_hooks
          return unless resource.previous_changes["registrations_enabled"].present? && resource.registrations_enabled?

          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.registrations_enabled",
            event_class: Decidim::Meetings::MeetingRegistrationsEnabledEvent,
            resource:,
            followers: resource.followers
          )
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
      end
    end
  end
end
