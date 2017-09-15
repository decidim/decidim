# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This module, when injected into a controller, ensures there's a
    # Participatory Process available and deducts it from the context.
    module NeedsParticipatoryProcess
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_participatory_process
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
        # Public: Finds the current Participatory Process given this controller's
        # context.
        #
        # Returns the current ParticipatoryProcess.
        def current_participatory_process
          @current_participatory_process ||= detect_participatory_process
        end

        alias current_participatory_space current_participatory_process

        private

        def ability_context
          super.merge(current_participatory_process: current_participatory_process)
        end

        def detect_participatory_process
          request.env["current_participatory_process"] ||
            organization_processes.where(slug: params[:participatory_process_slug] || params[:slug]).or(
              organization_processes.where(id: params["participatory_process_id"])
            ).first
        end

        def organization_processes
          @organization_processes ||= OrganizationParticipatoryProcesses.new(current_organization).query
        end
      end
    end
  end
end
