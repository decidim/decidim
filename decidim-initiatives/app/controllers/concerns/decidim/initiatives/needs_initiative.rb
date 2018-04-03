# frozen_string_literal: true

module Decidim
  module Initiatives
    # This module, when injected into a controller, ensures there's an
    # initiative available and deducts it from the context.
    module NeedsInitiative
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_initiative
        end
      end

      def self.extended(base)
        base.extend Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      def self.included(base)
        base.include Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      module InstanceMethods
        include InitiativeSlug

        # Public: Finds the current Initiative given this controller's
        # context.
        #
        # Returns the current Initiative.
        def current_initiative
          @current_initiative ||= detect_initiative
        end

        alias current_participatory_space current_initiative

        private

        def ability_context
          super.merge(current_participatory_space: current_initiative)
        end

        def detect_initiative
          request.env["current_initiative"] ||
            Initiative.find_by(
              id: (id_from_slug(params[:slug]) || id_from_slug(params[:initiative_slug]) || params[:initiative_id] || params[:id]),
              organization: current_organization
            )
        end
      end
    end
  end
end
