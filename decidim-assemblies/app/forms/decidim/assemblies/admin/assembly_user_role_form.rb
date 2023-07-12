# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A form object used to create assembly user roles from the admin dashboard.
      #
      class AssemblyUserRoleForm < Decidim::Admin::ParticipatorySpaceAdminUserForm
        mimic :assembly_user_role

        def scope = "decidim.admin.models.assembly_user_role.roles"
      end
    end
  end
end
