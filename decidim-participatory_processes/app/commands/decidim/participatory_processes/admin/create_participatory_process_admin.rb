# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateParticipatoryProcessAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def event = "decidim.events.participatory_process.role_assigned"

        def event_class = Decidim::ParticipatoryProcessRoleAssignedEvent

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
      end
    end
  end
end
