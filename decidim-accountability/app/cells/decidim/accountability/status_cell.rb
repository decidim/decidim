# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    # This cell renders the status of a taxonomy or a result.
    class StatusCell < Decidim::ViewModel
      include Decidim::Accountability::ApplicationHelper
      include Decidim::Accountability::BreadcrumbHelper
      include ActionView::Helpers::NumberHelper

      def show
        return unless render?

        render
      end

      def render?
        options[:render_blank] || has_results?
      end

      def has_results?
        results_count&.positive? || progress.present?
      end

      private

      def url
        options[:url]
      end

      def title
        if model.is_a? Decidim::Taxonomy
          decidim_escape_translated(model.name)
        else
          options[:title]
        end
      end

      def results_count
        @results_count ||= if model.is_a? Decidim::Taxonomy
                             count_calculator(model.id)
                           else
                             options[:count]
                           end
      end

      def progress
        if model.is_a? Decidim::Taxonomy
          progress_calculator(model.id).presence
        elsif model.respond_to?(:progress)
          model.progress
        else
          options[:progress] || progress_calculator(nil).presence
        end
      end

      def extra_classes
        options[:extra_classes]
      end

      def count
        return unless results_count&.positive? && render_count

        display_count(results_count)
      end

      def display_count(count)
        heading_parent_level_results(count)
      end

      def heading_parent_level_results(count)
        t("results.count.results_count", scope: "decidim.accountability", count:)
      end

      def render_count
        return true unless options.has_key?(:render_count)

        options[:render_count]
      end

      def count_calculator(taxonomy_id)
        Decidim::Accountability::ResultsCalculator.new(current_component, taxonomy_id).count
      end

      def decidim
        Decidim::Accountability::Engine.routes.url_helpers
      end
    end
  end
end
