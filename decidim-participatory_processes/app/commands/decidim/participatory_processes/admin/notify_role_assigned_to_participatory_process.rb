# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command to notify users when a role is assigned for a participatory process
      class NotifyRoleAssignedToParticipatoryProcess < Rectify::Command
        def send_notification(user)
          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.role_assigned",
            event_class: Decidim::ParticipatoryProcessRoleAssignedEvent,
            resource: form.current_participatory_space,
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
