# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateAssemblyAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event = "decidim.events.assembly.role_assigned"

        def event_class = Decidim::RoleAssignedToAssemblyEvent

        def existing_role
          Decidim::AssemblyUserRole.exists?(
            role: form.role.to_sym,
            user:,
            assembly: participatory_space
          )
        end

        # existing
        def create_role
          extra_info = {
            resource: {
              title: user.name
            }
          }
          role_params = {
            role: form.role.to_sym,
            user:,
            assembly: participatory_space
          }

          Decidim.traceability.create!(Decidim::AssemblyUserRole, current_user, role_params, extra_info)
          send_notification user
        end
      end
    end
  end
end
