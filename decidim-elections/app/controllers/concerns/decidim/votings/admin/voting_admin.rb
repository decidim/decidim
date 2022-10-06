# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Admin
      # This concern is meant to be included in all controllers that are scoped
      # into a voting admin panel. It will override the layout so it shows
      # the sidebar, preload the voting, etc.
      module VotingAdmin
        extend ActiveSupport::Concern

        RegistersPermissions
          .register_permissions(::Decidim::Votings::Admin::VotingAdmin,
                                Decidim::Votings::Permissions,
                                Decidim::Admin::Permissions)

        included do
          include Decidim::Admin::ParticipatorySpaceAdminContext
          participatory_space_admin_layout

          helper_method :current_voting

          def current_voting
            @current_voting ||= organization_votings.find_by!(
              slug: params[:voting_slug] || params[:slug]
            )
          end

          alias_method :current_participatory_space, :current_voting

          def organization_votings
            @organization_votings ||= OrganizationVotings.new(current_organization).query
          end

          def permissions_context
            super.merge(current_participatory_space:)
          end

          def permission_class_chain
            PermissionsRegistry.chain_for(VotingAdmin)
          end
        end
      end
    end
  end
end
