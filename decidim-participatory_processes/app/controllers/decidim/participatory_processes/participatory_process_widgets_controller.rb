# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessWidgetsController < Decidim::WidgetsController
      private

      def model
        @model ||= ParticipatoryProcess.where(slug: params[:participatory_process_slug]).first
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= participatory_process_participatory_process_widget_url(model)
      end
    end
  end
end
