# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyWidgetsController < Decidim::WidgetsController
      private

      def model
        @model ||= Assembly.where(slug: params[:assembly_slug]).first
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
