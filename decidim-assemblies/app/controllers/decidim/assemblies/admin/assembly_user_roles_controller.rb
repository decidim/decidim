# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing assembly user roles.
      #
      class AssemblyUserRolesController < Decidim::Assemblies::Admin::ApplicationController
        include Concerns::AssemblyAdmin
        include Decidim::Admin::ParticipatorySpace::UserRoleController

        def authorization_scope = :assembly_user_role

        def resource_form = form(AssemblyUserRoleForm)

        def space_index_path = assembly_user_roles_path(current_participatory_space)

        def i18n_scope = "decidim.admin.assembly_user_roles"

        def create_command = Decidim::Assemblies::Admin::CreateAssemblyAdmin

        def update_command = Decidim::Assemblies::Admin::UpdateAssemblyAdmin

        def role_class = Decidim::AssemblyUserRole
      end
    end
  end
end
