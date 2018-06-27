# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessFiltersCell < Decidim::ViewModel
      ALL_FILTERS = %w(active past upcoming all).freeze

      def filter_link(filter)
        Decidim::ParticipatoryProcesses::Engine
          .routes
          .url_helpers
          .participatory_processes_path(filter: filter)
      end

      def current_filter
        options[:current_filter]
      end

      def other_filters
        @other_filters ||= ALL_FILTERS - [current_filter]
      end

      def other_filters_with_value
        @other_filters_with_value ||= other_filters.select do | filter|
          model[filter] > 0
        end
      end

      def should_show_tabs?
        other_filters_with_value.any?
          other_filters_with_value != ["all"]
      end

      def title
        model[current_filter].to_s + " #{current_filter}"
      end

      def explanation
        return if model["active"] > 0
        content_tag(:span, explanation_text, class: "muted mr-s ml-s")
      end

      def explanation_text
        return "no_active" if model["upcoming"] > 0
        "no_active_or_upcoming"
      end
    end
  end
end
