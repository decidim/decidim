# frozen_string_literal: true

module Decidim
  module Debates
    # Exposes the debate resource so users can view them
    class DebatesController < Decidim::Debates::ApplicationController
      helper Decidim::ApplicationHelper
      include FilterResource

      helper_method :debates, :debate

      private

      def debates
        @debates ||= search.results
      end

      def debate
        @debate ||= debates.find(params[:id])
      end

      def search_klass
        DebateSearch
      end

      def default_search_params
        {
          page: params[:page],
          per_page: 12
        }
      end

      def default_filter_params
        {
          order_start_time: "asc",
          category_id: ""
        }
      end
    end
  end
end
