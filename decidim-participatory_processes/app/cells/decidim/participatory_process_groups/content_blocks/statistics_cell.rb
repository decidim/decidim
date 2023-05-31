# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class StatisticsCell < Decidim::StatisticsCell
        def stats
          @stats ||= begin
            participatory_process_group = Decidim::ParticipatoryProcessGroup.find(model.scoped_resource_id)
            Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupStatsPresenter.new(participatory_process_group:).collection
          end
        end
      end
    end
  end
end
