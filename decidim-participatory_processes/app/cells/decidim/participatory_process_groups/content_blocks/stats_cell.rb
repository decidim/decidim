# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class StatsCell < Decidim::ViewModel
        def stats
          @stats ||= Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupStatsPresenter.new(participatory_process_group: participatory_process_group)
        end

        def participatory_process_group
          @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(model.scoped_resource_id)
        end
      end
    end
  end
end
