# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource

      helper Decidim::TraceabilityHelper
      helper Decidim::Accountability::BreadcrumbHelper
      helper Decidim::Accountability::CalculatorHelper

      helper_method :results, :result, :selected_root_taxonomy, :selected_taxonomy_children, :selected_taxonomy_grandchildren?

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
        @result ||= search_collection.includes(:milestones).find_by(id: params[:id])
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

      def selected_taxonomy_grandchildren?
        @selected_taxonomy_grandchildren ||= selected_root_taxonomy.all_children.count > selected_taxonomy_children.count
      end

      def selected_taxonomy_children
        return [] if selected_root_taxonomy.blank?

        @selected_taxonomy_children ||= current_organization.taxonomies.where(parent_id: selected_root_taxonomy.id, id: current_component.available_taxonomy_ids)
      end

      def selected_root_taxonomy
        @selected_root_taxonomy ||= if params[:root_taxonomy_id] == "list"
                                      nil
                                    elsif params[:root_taxonomy_id].blank?
                                      current_component.available_root_taxonomies.find_by(id: component_settings.default_taxonomy)
                                    else
                                      current_component.available_root_taxonomies.find_by(id: params[:root_taxonomy_id])
                                    end
      end

      def add_parent_breadcrumb_item
        return {} if result&.parent.blank?

        {
          label: translated_attribute(result.parent.title),
          url: Decidim::EngineRouter.main_proxy(current_component).result_path(result.parent),
          active: true
        }
      end

      def add_breadcrumb_item
        return {} if result.blank?

        {
          label: translated_attribute(result.title),
          url: Decidim::EngineRouter.main_proxy(current_component).result_path(result),
          active: false
        }
      end
    end
  end
end
