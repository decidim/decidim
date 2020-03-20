# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command to notify users when a role is assigned for a participatory process
      class NotifyRoleAssignedParticipatoryProcess < Rectify::Command
        def send_notification user
            Decidim::EventsManager.publish(
              event: "decidim.events.participatory_process.role_assigned",
              event_class: Decidim::ParticipatoryProcessRoleAssignedEvent,
              resource: @participatory_process,
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