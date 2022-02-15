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
                      .result
                      .includes(:category)

        @sortitions = paginate(@sortitions)
        @sortitions = reorder(@sortitions)
      end

      def show
        raise ActionController::RoutingError, "Not Found" unless sortition
      end

      private

      def sortition
        search_collection.find_by(id: params[:id])
      end

      def search_collection
        Sortition.where(component: current_component)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_category: "",
          with_any_state: "active"
        }
      end
    end
  end
end
