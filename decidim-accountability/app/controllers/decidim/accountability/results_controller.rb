# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource
      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper

      helper_method :results, :result, :first_class_taxonomies, :count_calculator

      before_action :set_controller_breadcrumb

      def show
        raise ActionController::RoutingError, "Not Found" unless result
      end

      def home
        @all_geocoded_results = results.geocoded
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

      def search_collection
        Result.where(component: current_component)
      end

      def default_filter_params
        {
          search_text_cont: "",
          taxonomies_part_of_contains: ""
        }
      end

      def first_class_taxonomies
        @first_class_taxonomies ||= current_organization.taxonomies.where(parent_id: current_component.available_root_taxonomies, id: current_component.available_taxonomy_ids)
      end

      def count_calculator(taxonomy_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, taxonomy_id).count
      end

      def controller_breadcrumb_items
        @controller_breadcrumb_items ||= []
      end

      def set_controller_breadcrumb
        controller_breadcrumb_items << breadcrumb_item
      end

      def breadcrumb_item
        return {} if result&.parent.blank?

        {
          label: translated_attribute(result.parent.title),
          url: result_path(result.parent),
          active: true
        }
      end
    end
  end
end
