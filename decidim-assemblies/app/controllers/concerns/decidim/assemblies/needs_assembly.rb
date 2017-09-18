# frozen_string_literal: true

module Decidim
  module Assemblies
    # This module, when injected into a controller, ensures there's a
    # Assembly available and deducts it from the context.
    module NeedsAssembly
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_assembly
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
        # Public: Finds the current Assembly given this controller's
        # context.
        #
        # Returns the current Assembly.
        def current_assembly
          @current_assembly ||= detect_assembly
        end

        alias current_participatory_space current_assembly

        private

        def ability_context
          super.merge(current_assembly: current_assembly)
        end

        def detect_assembly
          request.env["current_assembly"] ||
            organization_assemblies.where(slug: params[:assembly_slug] || params[:slug]).or(
              organization_assemblies.where(id: params[:assembly_id])
            ).first
        end

        def organization_assemblies
          @organization_assemblies ||= OrganizationAssemblies.new(current_organization).query
        end
      end
    end
  end
end
