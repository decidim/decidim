# frozen_string_literal: true

module Decidim
  module Results
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Results::ApplicationController
      include FilterResource

      helper_method :results, :result

      def index; end

      private

      def results
        @results ||= search.results
      end

      def result
        @result ||= results.find(params[:id])
      end

      def search_klass
        ResultSearch
      end

      def default_search_params
        {
          page: params[:page],
          per_page: 12
        }
      end

      def default_filter_params
        {
          search_text: "",
          scope_id: "",
          category_id: ""
        }
      end

      def context_params
        {feature: current_feature, organization: current_organization }
      end
    end
  end
end
