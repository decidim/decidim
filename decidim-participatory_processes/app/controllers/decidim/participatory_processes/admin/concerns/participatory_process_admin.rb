# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatoryProcesses
    module Admin
      module Concerns
        # This concern is meant to be included in all controllers that are scoped
        # into a participatory process' admin panel. It will override the layout
        # so it shows the sidebar, preload the participatory process, etc.
        module ParticipatoryProcessAdmin
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::ParticipatorySpaceAdminContext
            helper_method :current_participatory_process
            participatory_space_admin_layout

            def organization_processes
              @organization_processes ||= OrganizationParticipatoryProcesses.new(current_organization).query
            end

            def current_participatory_space
              request.env["current_participatory_space"] ||
                organization_processes.find_by!(slug: params[:participatory_process_slug] || params[:slug])
            end

            def permissions_context
              super.merge(current_participatory_space: current_participatory_space)
            end

            alias_method :current_participatory_process, :current_participatory_space

            def permission_class_chain
              [
                Decidim::ParticipatoryProcesses::Permissions,
                Decidim::Admin::Permissions
              ]
            end
          end
        end
      end
    end
  end
end
