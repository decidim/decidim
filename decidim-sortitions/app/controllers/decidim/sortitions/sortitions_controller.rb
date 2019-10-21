# frozen_string_literal: true

module Decidim
  module Sortitions
    # Exposes the sortition resource so users can view them
    class SortitionsController < Decidim::Sortitions::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include FilterResource
      include Decidim::Sortitions::Orderable
      include Paginable

      helper_method :sortition

      helper Decidim::Proposals::ApplicationHelper

      def index
        @sortitions = search
                      .results
                      .includes(:author)
                      .includes(:category)

        @sortitions = paginate(@sortitions)
        @sortitions = reorder(@sortitions)
      end

      private

      def sortition
        Sortition.find(params[:id])
      end

      def search_klass
        SortitionSearch
      end

      def default_filter_params
        {
          search_text: "",
          category_id: "",
          state: "active"
        }
      end
    end
  end
end
