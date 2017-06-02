# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module, when injected into a controller, ensures there's a
  # Participatory Process available and deducts it from the context.
  module NeedsParticipatoryProcess
    extend ActiveSupport::Concern

    include NeedsOrganization

    included do
      after_action :verify_participatory_process
      helper_method :current_participatory_process

      # Public: Finds the current Participatory Process given this controller's
      # context.
      #
      # Returns the current ParticipatoryProcess.
      def current_participatory_process
        @current_participatory_process ||= detect_participatory_process
      end

      private

      def verify_participatory_process
        raise ActionController::RoutingError, "Participatory process not found." unless current_participatory_process
      end

      def detect_participatory_process
        request.env["current_participatory_process"] ||
          current_organization.participatory_processes.find_by(id: params[:participatory_process_id] || params[:id])
      end
    end
  end
end
