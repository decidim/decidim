# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Assemblies
    module Admin
      module Concerns
        # This concern is meant to be included in all controllers that are scoped
        # into an assembly's admin panel. It will override the layout so it shows
        # the sidebar, preload the assembly, etc.
        module AssemblyAdmin
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::ParticipatorySpaceAdminContext
            participatory_space_admin_layout

            helper_method :current_assembly
            alias_method :current_participatory_space, :current_assembly
          end

          def current_assembly
            @current_assembly ||= organization_assemblies.find_by!(
              slug: params[:assembly_slug] || params[:slug]
            )
          end

          def organization_assemblies
            @organization_assemblies ||= OrganizationAssemblies.new(current_organization).query
          end
        end
      end
    end
  end
end
