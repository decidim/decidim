# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class RelatedProcessesCell < Decidim::ContentBlocks::BaseCell
        def show
          render if total_count.positive?
        end

        def related_processes
          @related_processes ||=
            resource
            .linked_participatory_space_resources(:participatory_processes, link_name)
            .published
            .all
        end

        def total_count
          related_processes.size
        end

        private

        def link_name
          resource.is_a?(Decidim::ParticipatoryProcess) ? "related_processes" : "included_participatory_processes"
        end

        def limit
          model.settings.try(:max_results)
        end
      end
    end
  end
end
