# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This query class filters public processes given an organization in a
    # meaningful prioritized order.
    class FilteredParticipatoryProcessGroups < Rectify::Query
      def initialize(filter = "active")
        @filter = filter
      end

      def query
        processes = Decidim::ParticipatoryProcess.all

        processes = case @filter
                    when "past"
                      processes.where("decidim_participatory_processes.end_date <= ?", Time.current)
                    when "upcoming"
                      processes.where("decidim_participatory_processes.start_date > ?", Time.current)
                    else
                      processes
                    end

        Decidim::ParticipatoryProcessGroup.where(id: processes.pluck(:decidim_participatory_process_group_id))
      end
    end
  end
end
