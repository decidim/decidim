# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource
      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper

      helper_method :results, :result, :first_class_categories, :count_calculator, :nav_paths

      def show
        raise ActionController::RoutingError, "Not Found" unless result
      end

      private

      def results
        @results ||= begin
          parent_id = params[:parent_id].presence
          search.result.where(
            parent_id: [parent_id] + Result.where(parent_id:).pluck(:id)
          ).page(params[:page]).per(12)
        end
      end

      def result
        @result ||= search_collection.includes(:timeline_entries).find_by(id: params[:id])
      end

      def next_result
        return if search_collection.size < 2

        search_collection.order(:start_date, :id).where(Decidim::Accountability::Result.arel_table[:id].gt(result.id)).first
      end

      def prev_result
        return if search_collection.size < 2

        search_collection.order(:start_date, :id).where(Decidim::Accountability::Result.arel_table[:id].lt(result.id)).last
      end

      def nav_paths
        return {} if result.blank?

        { prev_path: prev_result, next_path: next_result }.compact_blank.transform_values { |result| result_path(result) }
      end

      def search_collection
        Result.where(component: current_component)
      end

      def default_filter_params
        {
          search_text_cont: "",
          with_scope: "",
          with_category: ""
        }
      end

      def first_class_categories
        @first_class_categories ||= current_participatory_space.categories.first_class
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, scope_id, category_id).count
      end
    end
  end
end
