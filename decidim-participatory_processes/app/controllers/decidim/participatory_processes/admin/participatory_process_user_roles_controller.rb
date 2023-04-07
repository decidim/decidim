# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing participatory process user roles.
      #
      class ParticipatoryProcessUserRolesController < Decidim::Admin::ApplicationController
        include Concerns::ParticipatoryProcessAdmin
        include Decidim::Admin::ParticipatorySpace::UserRoleController

        def authorization_scope = :process_user_role

        def resource_form = form(ParticipatoryProcessUserRoleForm)

        def space_index_path = participatory_process_user_roles_path(current_participatory_space)

        def i18n_scope = "decidim.admin.participatory_process_user_roles"

        def create_command = Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessAdmin

        def update_command = Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcessAdmin

        def role_class = Decidim::ParticipatoryProcessUserRole

      end
    end
  end
end
