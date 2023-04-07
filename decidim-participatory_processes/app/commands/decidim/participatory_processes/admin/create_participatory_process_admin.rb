# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateParticipatoryProcessAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        include ::Decidim::Admin::CreateParticipatorySpaceAdminUserActions

        private

        attr_reader :form, :participatory_space, :current_user, :user

        def create_role
          extra_info = {
            resource: {
              title: user.name
            }
          }
          role_params = {
            role: form.role.to_sym,
            user:,
            participatory_process: participatory_space
          }

          Decidim.traceability.create!(
            Decidim::ParticipatoryProcessUserRole,
            current_user,
            role_params,
            extra_info
          )
          send_notification user
        end

        def existing_role
          Decidim::ParticipatoryProcessUserRole.exists?(
            role: form.role.to_sym,
            user:,
            participatory_process: participatory_space
          )
        end

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
