# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # This module, when injected into a controller, ensures there is an
    # initiative available and deducts it from the context.
    module NeedsInitiative
      extend ActiveSupport::Concern

      RegistersPermissions
        .register_permissions("#{::Decidim::Initiatives::NeedsInitiative.name}/admin",
                              Decidim::Initiatives::Permissions,
                              Decidim::Admin::Permissions)
      RegistersPermissions
        .register_permissions("#{::Decidim::Initiatives::NeedsInitiative.name}/public",
                              Decidim::Initiatives::Permissions,
                              Decidim::Admin::Permissions,
                              Decidim::Permissions)

      included do
        include NeedsOrganization
        include InitiativeSlug

        helper_method :current_initiative, :current_participatory_space

        # Public: Finds the current Initiative given this controller's
        # context.
        #
        # Returns the current Initiative.
        def current_initiative
          @current_initiative ||= detect_initiative
        end

        alias_method :current_participatory_space, :current_initiative

        private

        def detect_initiative
          request.env["current_initiative"] ||
            Initiative.find_by(
              id: id_from_slug(params[:slug]) || id_from_slug(params[:initiative_slug]) || params[:initiative_id] || params[:id],
              organization: current_organization
            )
        end

        def permission_class_chain
          if permission_scope == :admin
            PermissionsRegistry.chain_for("#{::Decidim::Initiatives::NeedsInitiative.name}/admin")
          else
            PermissionsRegistry.chain_for("#{::Decidim::Initiatives::NeedsInitiative.name}/public")
          end
        end
      end
    end
  end
end
