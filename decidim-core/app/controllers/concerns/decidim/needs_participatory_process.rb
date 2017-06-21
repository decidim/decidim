# frozen_string_literal: true

module Decidim
  # This module, when injected into a controller, ensures there's a
  # Participatory Process available and deducts it from the context.
  module NeedsParticipatoryProcess
    def self.enhance_controller(instance_or_module)
      instance_or_module.class_eval do
        helper_method :current_participatory_process
      end
    end

    def self.extended(base)
      base.extend NeedsOrganization, InstanceMethods

      enhance_controller(base)
    end

    def self.included(base)
      base.include NeedsOrganization, InstanceMethods

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

      private

      def ability_context
        super.merge(current_participatory_process: current_participatory_process)
      end

      def detect_participatory_process
        request.env["current_participatory_process"] ||
          current_organization.participatory_processes.find(params[:participatory_process_id] || params[:id])
      end
    end
  end
end
