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

        def destroy_command = Decidim::ParticipatoryProcesses::Admin::DestroyParticipatoryProcessAdmin

        def create_command = Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcessAdmin

        def update_command = Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcessAdmin

        private

        def collection
          @collection ||= Decidim::ParticipatoryProcessUserRole
                          .joins(:user)
                          .where(participatory_process: current_participatory_process)
        end
      end
    end
  end
end
