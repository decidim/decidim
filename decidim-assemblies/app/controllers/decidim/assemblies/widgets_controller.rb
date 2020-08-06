# frozen_string_literal: true

module Decidim
  module Assemblies
    class WidgetsController < Decidim::WidgetsController
      helper Decidim::SanitizeHelper

      private

      def model
        @model ||= Assembly.find_by(slug: params[:assembly_slug])
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= assembly_widget_url(model)
      end
    end
  end
end
