# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly user roles.
      #
      class AssemblyUserRolesController < Decidim::Admin::ParticipatorySpace::UserRoleController
        include Concerns::AssemblyAdmin

        def authorization_scope = :assembly_user_role

        def resource_form = form(AssemblyUserRoleForm)

        def space_index_path = assembly_user_roles_path(current_participatory_space)

        def i18n_scope = "decidim.admin.assembly_user_roles"

        def role_class = Decidim::AssemblyUserRole

        def event = "decidim.events.assembly.role_assigned"

        def event_class = Decidim::RoleAssignedToAssemblyEvent
      end
    end
  end
end
