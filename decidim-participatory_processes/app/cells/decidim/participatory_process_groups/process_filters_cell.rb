# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    # This cell renders the filter tabs of participatory processes
    # in a group. It's inherited from ProcessFiltersCell of participatory
    # processes index but is based in the group processes
    #
    # The `model` must be a Decidim::ParticipatoryProcessGroup`
    #
    # Available options:
    #
    # - `:base_relation` => A relation of participatory processes. If not
    #   provided is based on the model processes using
    #   GroupPublishedParticipatoryProcesses query.
    # - `default_date_filter` => The date filter to use if not given by
    #    params. If not provided is inferred from the base relation
    #
    # Example:
    #
    # cell(
    #   "decidim/participatory_process_groups/process_filters",
    #   group,
    #   base_relation: group.participatory_processes.published,
    #   date_filter: "active"
    # )
    class ProcessFiltersCell < Decidim::ParticipatoryProcesses::ProcessFiltersCell
      def filter_link(date_filter, type_filter = nil)
        Decidim::ParticipatoryProcesses::Engine
          .routes
          .url_helpers
          .participatory_process_group_path(model, **filter_params(date_filter, type_filter))
      end

      def current_filter
        get_filter(:with_date, default_date_filter)
      end

      def base_relation
        @base_relation ||= options[:base_relation].presence || Decidim::ParticipatoryProcesses::GroupPublishedParticipatoryProcesses.new(
          model,
          current_user
        ).query
      end

      def process_count_by_filter
        @process_count_by_filter ||= begin
          counts = ALL_FILTERS.without("all").each_with_object({}) do |filter_name, collection_by_filter|
            collection_by_filter.update(filter_name => filtered_processes(filter_name).count)
          end
          counts.update("all" => counts.values.sum)
        end
      end

      def filtered_processes(date_filter, filter_with_type: true)
        query = base_relation.ransack(
          {
            with_date: date_filter,
            with_scope: get_filter(:with_scope),
            with_area: get_filter(:with_area),
            with_type: filter_with_type ? get_filter(:with_type) : nil
          },
          current_user:,
          organization: current_organization
        ).result

        query.published.visible_for(current_user)
      end

      def default_date_filter
        @default_date_filter ||= options[:default_filter].presence || process_count_by_filter.find { |_, count| count.positive? }&.first || "all"
      end
    end
  end
end
