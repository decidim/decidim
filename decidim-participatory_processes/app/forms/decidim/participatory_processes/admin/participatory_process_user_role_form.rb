# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A form object used to create participatory process user roles from the
      # admin dashboard.
      #
      class ParticipatoryProcessUserRoleForm < Decidim::Admin::ParticipatorySpaceAdminUserForm
        mimic :participatory_process_user_role

        def scope = "decidim.admin.models.participatory_process_user_role.roles"
      end
    end
  end
end
