# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessWidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      private

      def model
        return unless params[:participatory_process_slug]

        @model ||= ParticipatoryProcess.where(slug: params[:participatory_process_slug]).or(
          ParticipatoryProcess.where(id: params[:participatory_process_slug])
        ).first!
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= participatory_process_participatory_process_widget_url(model)
      end

      def current_participatory_space_manifest_name
        :participatory_processes
      end
    end
  end
end
