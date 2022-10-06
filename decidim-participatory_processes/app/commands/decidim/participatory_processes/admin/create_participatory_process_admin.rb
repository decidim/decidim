# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateParticipatoryProcessAdmin < NotifyRoleAssignedToParticipatoryProcess
        include ::Decidim::Admin::CreateParticipatorySpaceAdminUserActions

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # current_user - the user performing this action
        # participatory_process - The ParticipatoryProcess that will hold the
        #   user role
        def initialize(form, current_user, participatory_process)
          @form = form
          @current_user = current_user
          @participatory_space = participatory_process
        end

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
      end
    end
  end
end
