# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # This module, when injected into a controller, ensures there's an
    # initiative available and deducts it from the context.
    module NeedsInitiative
      extend ActiveSupport::Concern

      included do
        include NeedsOrganization
        include InitiativeSlug

        helper_method :current_initiative

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
              id: (id_from_slug(params[:slug]) || id_from_slug(params[:initiative_slug]) || params[:initiative_id] || params[:id]),
              organization: current_organization
            )
        end

        def permission_class_chain
          list = [
            Decidim::Initiatives::Permissions,
            Decidim::Admin::Permissions
          ]

          return list if permission_scope == :admin
          list << Decidim::Permissions
        end
      end
    end
  end
end
