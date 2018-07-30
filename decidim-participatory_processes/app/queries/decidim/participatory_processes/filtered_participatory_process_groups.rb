# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes groups given a filter name.
    # The filter is applied checking the start and end dates of the processes in
    # the group.
    class FilteredParticipatoryProcessGroups < Rectify::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        processes = case @filter
                    when "past"
                      processes.where("decidim_participatory_processes.end_date <= ?", Date.current)
                    when "upcoming"
                      processes.where("decidim_participatory_processes.start_date > ?", Date.current)
                    else
                      processes
                    end

        Decidim::ParticipatoryProcessGroup.where(id: processes.pluck(:decidim_participatory_process_group_id))
      end
    end
  end
end
