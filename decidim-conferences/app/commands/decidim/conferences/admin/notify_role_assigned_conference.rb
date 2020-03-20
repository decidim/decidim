# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
    # A command to notify users when a role is assigned for a Conference
      class NotifyRoleAssignedConference < Rectify::Command
        def send_notification user
            Decidim::EventsManager.publish(
            event: "decidim.events.conferences.role_assigned",
            event_class: Decidim::Conferences::ConferenceRoleAssignedEvent,
            resource: @conference,
            affected_users: [user],
            extra: {
                role: form.role
            }
            )
        end
      end
    end
  end
end