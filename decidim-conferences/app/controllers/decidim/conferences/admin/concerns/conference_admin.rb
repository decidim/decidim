# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Conferences
    module Admin
      module Concerns
        # This concern is meant to be included in all controllers that are scoped
        # into an conference's admin panel. It will override the layout so it shows
        # the sidebar, preload the conference, etc.
        module ConferenceAdmin
          extend ActiveSupport::Concern

          RegistersPermissions
            .register_permissions(::Decidim::Conferences::Admin::Concerns::ConferenceAdmin,
                                  ::Decidim::Conferences::Permissions,
                                  ::Decidim::Admin::Permissions)

          included do
            include Decidim::Admin::ParticipatorySpaceAdminContext
            participatory_space_admin_layout

            helper_method :current_conference

            def current_conference
              @current_conference ||= organization_conferences.find_by!(
                slug: params[:conference_slug] || params[:slug]
              )
            end

            alias_method :current_participatory_space, :current_conference

            def organization_conferences
              @organization_conferences ||= OrganizationConferences.new(current_organization).query
            end

            def permissions_context
              super.merge(current_participatory_space:)
            end

            def permission_class_chain
              PermissionsRegistry.chain_for(ConferenceAdmin)
            end
          end
        end
      end
    end
  end
end
