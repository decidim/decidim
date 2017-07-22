# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyWidgetsController < Decidim::WidgetsController
      private

      def model
        @model ||= Assembly.find(params[:assembly_id])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= assembly_assembly_widget_url(model)
      end
    end
  end
end
