# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateAssemblyAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        include ::Decidim::Admin::CreateParticipatorySpaceAdminUserActions

        private

        attr_reader :form, :participatory_space, :current_user, :user

        def existing_role
          Decidim::AssemblyUserRole.exists?(
            role: form.role.to_sym,
            user:,
            assembly: @participatory_process
          )
        end

        def create_role
          Decidim.traceability.perform_action!(
            :create,
            Decidim::AssemblyUserRole,
            current_user,
            resource: {
              title: user.name
            }
          ) do
            Decidim::AssemblyUserRole.find_or_create_by!(
              role: form.role.to_sym,
              user:,
              assembly: participatory_space
            )
          end
          send_notification user
        end

        def send_notification(user)
          Decidim::EventsManager.publish(
            event: "decidim.events.assembly.role_assigned",
            event_class: Decidim::RoleAssignedToAssemblyEvent,
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
