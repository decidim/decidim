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
        Decidim::Accountability::ResultsCalculator.new(current_feature, scope_id, category_id).progress
      end

      def category
        if params[:filter] && params[:filter][:category_id].present?
          current_participatory_space.categories.find(params[:filter][:category_id])
        end
      end
    end
  end
end
