# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class RelatedProcessesCell < Decidim::ContentBlocks::BaseCell
        def related_processes
          @related_processes ||=
            resource
            .linked_participatory_space_resources(:participatory_processes, "related_processes")
            .published
            .all
        end

        def total_count
          related_processes.size
        end

        private

        def limit
          model.settings.try(:max_results)
        end
      end
    end
  end
end
