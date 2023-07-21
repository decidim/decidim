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

        def filtered_processes
          return related_processes unless filter_active?

          related_processes.active
        end

        def total_count
          filtered_processes.size
        end

        private

        def filter_active?
          default_filter == "active"
        end

        def default_filter
          return if model.blank?

          model.settings.try(:default_filter)
        end

        def title
          if filter_active?
            t("active", scope: "decidim.participatory_process_groups.content_blocks.participatory_processes")
          else
            t("name", scope: "decidim.participatory_process_groups.content_blocks.participatory_processes")
          end
        end
      end
    end
  end
end
