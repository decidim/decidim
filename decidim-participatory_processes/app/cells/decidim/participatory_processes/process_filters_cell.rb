# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessFiltersCell < Decidim::ViewModel
      ALL_FILTERS = %w(active upcoming past all).freeze

      def filter_link(date_filter)
        Decidim::ParticipatoryProcesses::Engine
          .routes
          .url_helpers
          .participatory_processes_path(**filter_params(date_filter))
      end

      def current_filter
        get_filter_in(:with_date, ALL_FILTERS, model[:default_filter])
      end

      def get_filter(filter_name, default = nil)
        params&.dig(:filter, filter_name) || default
      rescue ActionController::InvalidParameterKey
        default
      end

      def get_filter_in(filter_name, options, default = nil)
        value = get_filter(filter_name)
        options.include?(value) ? value : default
      end

      def filter_params(date_filter)
        {
          filter: {
            with_date: date_filter,
            with_any_scope: get_filter(:with_any_scope),
            with_any_area: get_filter(:with_any_area)
          }
        }
      end

      def filtered_processes(date_filter)
        query = ParticipatoryProcess.where(organization: current_organization).ransack(
          {
            with_date: date_filter,
            with_any_scope: get_filter(:with_any_scope),
            with_any_area: get_filter(:with_any_area)
          },
          current_user:
        ).result

        query.published.visible_for(current_user)
      end

      def process_count_by_filter
        return @process_count_by_filter if @process_count_by_filter

        @process_count_by_filter = %w(active upcoming past).inject({}) do |collection_by_filter, filter_name|
          filtered_processes = filtered_processes(filter_name)
          processes = filtered_processes.groupless
          groups = Decidim::ParticipatoryProcessGroup.where(id: filtered_processes.grouped.group_ids)
          collection_by_filter.merge(filter_name => processes.count + groups.count)
        end
        @process_count_by_filter["all"] = @process_count_by_filter.values.sum
        @process_count_by_filter
      end

      def other_filters
        @other_filters ||= ALL_FILTERS - [current_filter]
      end

      def other_filters_with_value
        @other_filters_with_value ||= other_filters.select do |filter|
          process_count_by_filter[filter].positive?
        end
      end

      def should_show_tabs?
        other_filters_with_value.any? && other_filters_with_value != ["all"]
      end

      def title
        I18n.t(current_filter, scope: "decidim.participatory_processes.participatory_processes.filters.counters", count: process_count_by_filter[current_filter])
      end

      def filter_name(filter)
        I18n.t(filter, scope: "decidim.participatory_processes.participatory_processes.filters.names")
      end

      def explanation
        return if process_count_by_filter["active"].positive?

        content_tag(
          :span,
          I18n.t(explanation_text, scope: "decidim.participatory_processes.participatory_processes.filters.explanations")
        )
      end

      def explanation_text
        return "no_active" if process_count_by_filter["upcoming"].positive?

        "no_active_nor_upcoming"
      end
    end
  end
end
