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

        def filtered_processes
          return related_processes unless filter_active?

          related_processes.active
        end

        def limited_processes
          return filtered_processes unless limit?

          filtered_processes.limit(limit)
        end

        def total_count
          filtered_processes.size
        end

        private

        def resource
          options[:resource] || super
        end

        def limit
          @limit ||= model.settings.try(:max_results)
        end

        def filter_active?
          default_filter == "active"
        end

        def default_filter
          model.settings.try(:default_filter) || "active"
        end

        def limit?
          limit.to_i.positive?
        end
      end
    end
  end
end
