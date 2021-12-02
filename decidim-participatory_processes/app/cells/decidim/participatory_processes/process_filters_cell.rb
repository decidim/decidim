# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ProcessFiltersCell < Decidim::ViewModel
      ALL_FILTERS = %w(active upcoming past all).freeze

      def filter_link(date_filter, type_filter = nil)
        Decidim::ParticipatoryProcesses::Engine
          .routes
          .url_helpers
          .participatory_processes_path(**filter_params(date_filter, type_filter))
      end

      def current_filter
        get_filter(:date, model[:default_filter])
      end

      def current_type_filter_name
        participatory_process_types_for_select.find { |_, id| id == get_filter(:type_id) }&.first ||
          I18n.t("all_types", scope: "decidim.participatory_processes.participatory_processes.filters")
      end

      def get_filter(filter_name, default = nil)
        params&.dig(:filter, filter_name) || default
      end

      def filter_params(date_filter, type_filter)
        {
          filter: {
            scope_id: get_filter(:scope_id),
            area_id: get_filter(:area_id),
            type_id: type_filter || get_filter(:type_id),
            date: date_filter
          }
        }
      end

      def filtered_processes(date_filter, filter_by_type: true)
        ParticipatoryProcessSearch.new(
          date: date_filter,
          scope_id: get_filter(:scope_id),
          area_id: get_filter(:area_id),
          type_id: filter_by_type ? get_filter(:type_id) : nil,
          current_user: current_user,
          organization: current_organization
        )
      end

      def process_count_by_filter
        return @process_count_by_filter if @process_count_by_filter

        @process_count_by_filter = %w(active upcoming past).inject({}) do |collection_by_filter, filter_name|
          filtered_processes = filtered_processes(filter_name).results
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

      def filter_type_label
        I18n.t("filter_by", scope: "decidim.participatory_processes.participatory_processes.filters")
      end

      def filter_name(filter)
        I18n.t(filter, scope: "decidim.participatory_processes.participatory_processes.filters.names")
      end

      def explanation
        return if process_count_by_filter["active"].positive?

        content_tag(
          :span,
          I18n.t(explanation_text, scope: "decidim.participatory_processes.participatory_processes.filters.explanations"),
          class: "muted mr-s ml-s"
        )
      end

      def explanation_text
        return "no_active" if process_count_by_filter["upcoming"].positive?

        "no_active_nor_upcoming"
      end

      def participatory_process_types
        @participatory_process_types ||= Decidim::ParticipatoryProcessType.joins(:processes).where(
          decidim_participatory_processes: { id: filtered_processes(current_filter, filter_by_type: false).results }
        ).distinct
      end

      def participatory_process_types_for_select
        return if participatory_process_types.blank?

        [[I18n.t("all_types", scope: "decidim.participatory_processes.participatory_processes.filters"), ""]] +
          participatory_process_types.map do |type|
            [translated_attribute(type.title), type.id.to_s]
          end
      end
    end
  end
end
