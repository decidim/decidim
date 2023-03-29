# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class RelatedProcessesCell < Decidim::ParticipatoryProcesses::ContentBlocks::RelatedProcessesCell
        def related_processes
          @related_processes ||=
            Decidim::ParticipatoryProcesses::GroupPublishedParticipatoryProcesses.new(
              resource,
              current_user
            ).query
        end
      end
    end
  end
end
