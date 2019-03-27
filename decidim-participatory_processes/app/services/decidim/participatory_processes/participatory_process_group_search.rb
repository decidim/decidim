# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Service that encapsulates all logic related to filtering assemblies.
    class ParticipatoryProcessGroupSearch < SpaceSearch
      def initialize(options = {})
        super(ParticipatoryProcessGroup.all, options)
      end

      def search_date
        processes = Decidim::ParticipatoryProcess
        processes = case date
                    when "past"
                      processes.where("decidim_participatory_processes.end_date <= ?", Date.current)
                    when "upcoming"
                      processes.where("decidim_participatory_processes.start_date > ?", Date.current)
                    else # Assume 'all' | 'active'
                      processes
                    end
        query.where(id: processes.pluck(:decidim_participatory_process_group_id))
      end

    end
  end
end
