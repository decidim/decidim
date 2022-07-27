# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when creating a new participatory
      # process admin in the system.
      class CreateAssemblyAdmin < NotifyRoleAssignedToAssembly
        include ::Decidim::Admin::CreateParticipatorySpaceAdminUserActions

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # assembly - The Assembly that will hold the
        #   user role
        def initialize(form, current_user, assembly)
          @form = form
          @current_user = current_user
          @participatory_space = assembly
        end

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
      end
    end
  end
end
