# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class discards participatory process groups and
    # filters participatory processes given a filter name.
    # It uses the start and end dates to select the correct processes.
    class FilteredParticipatoryProcesses < Rectify::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess
                    .where(decidim_participatory_process_group_id: nil)

        case @filter
        when "active"
          processes.active.order(start_date: :desc)
        when "past"
          processes.past.order(end_date: :desc)
        when "upcoming"
          processes.upcoming.order(start_date: :asc)
        else
          current_zone = Time.zone
          processes.order(Arel.sql("ABS(start_date - (CURRENT_DATE at time zone '#{current_zone}')::date)"))
        end
      end
    end
  end
end
