# frozen_string_literal: true

module Decidim
  module Accountability
    # Exposes the result resource so users can view them
    class ResultsController < Decidim::Accountability::ApplicationController
      include FilterResource
      helper Decidim::WidgetUrlsHelper

      helper_method :results, :result, :stats_calculator, :first_class_categories, :category, :progress_calculator, :count_calculator, :current_scope, :template_texts

      def home
      end

      def csv
        send_data CSVExporter.new(current_feature).export, filename: "results.csv", disposition: "attachment"
      end

      private

      def results
        parent_id = params[:parent_id].presence
        @results ||= search.results.where(parent_id: parent_id).page(params[:page]).per(12)
      end

      def result
        @result ||= Result.includes(:timeline_entries).where(feature: current_feature).find(params[:id])
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

      def first_class_categories
        @first_class_categories ||= current_participatory_process.categories.first_class
      end

      def category
        if params[:filter] && params[:filter][:category_id].present?
          current_participatory_process.categories.find(params[:filter][:category_id])
        end
      end

      def progress_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_feature, scope_id, category_id).progress
      end

      def count_calculator(scope_id, category_id)
        Decidim::Accountability::ResultsCalculator.new(current_feature, scope_id, category_id).count
      end

      def current_scope
        params[:filter][:scope_id] if params[:filter]
      end

      def template_texts
        Decidim::Accountability::TemplateTexts.for(current_feature)
      end
    end
  end
end
