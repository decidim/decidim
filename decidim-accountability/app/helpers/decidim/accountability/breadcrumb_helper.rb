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
        params[:filter][:with_scope] if params[:filter]
      end

      def progress_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, scope_id, category_id).progress
      end

      def category
        return if (category_id = params.dig(:filter, :with_category)).blank?

        @category ||= current_participatory_space.categories.find(category_id.is_a?(Array) ? category_id.first : category_id)
      end
    end
  end
end
