# frozen_string_literal: true

module Decidim
  module Accountability
    # Helpers needed to render the navigation breadcrumbs in results.
    #
    module BreadcrumbHelper
      def stats_calculator
        @stats_calculator ||= ResultStatsCalculator.new(result)
      end

      def current_scope
        params[:filter][:scope_id] if params[:filter]
      end

      def progress_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, scope_id, category_id).progress
      end

      def category
        current_participatory_space.categories.find(params[:filter][:category_id]) if params[:filter] && params[:filter][:category_id].present?
      end
    end
  end
end
