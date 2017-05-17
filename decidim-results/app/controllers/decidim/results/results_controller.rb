# frozen_string_literal: true

module Decidim
  module Results
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Results::ApplicationController
      include FilterResource
      helper Decidim::WidgetUrlsHelper

      helper_method :results, :result, :stats_calculator

      private

      def results
        @results ||= search.results.order("title -> '#{I18n.locale}' ASC").page(params[:page]).per(12)
      end

      def result
        @result ||= results.find(params[:id])
      end

      def stats_calculator
        @stats_calculator ||= ResultStatsCalculator.new(result)
      end

      def search_klass
        ResultSearch
      end

      def default_filter_params
        {
          search_text: "",
          scope_id: "",
          category_id: ""
        }
      end

      def context_params
        { feature: current_feature, organization: current_organization }
      end
    end
  end
end
