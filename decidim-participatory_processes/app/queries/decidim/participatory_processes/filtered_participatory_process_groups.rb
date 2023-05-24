# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters participatory processes groups given a filter name.
    # The filter is applied checking the start and end dates of the processes in
    # the group.
    class FilteredParticipatoryProcessGroups < Decidim::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        processes = case @filter
                    when "past"
                      processes.past
                    when "upcoming"
                      processes.upcoming
                    when "active"
                      processes.active
                    else
                      processes
                    end

        Decidim::ParticipatoryProcessGroup.where(id: processes.pluck(:decidim_participatory_process_group_id))
      end
    end
  end
end
