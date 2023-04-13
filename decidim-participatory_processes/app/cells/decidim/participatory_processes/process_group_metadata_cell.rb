# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    class ProcessGroupMetadataCell < Decidim::CardMetadataCell
      delegate :active_step, :meta_scope, to: :model

      def initialize(*)
        super

        @items.prepend(*items)
      end

      private

      def items
        [processes_count_item, meta_scope_item].compact
      end

      def processes_count_item
        {
          icon: "grid-line",
          text: t(
            "decidim.participatory_process_groups.content_blocks.title.participatory_processes",
            # REDESIGN_PENDING: the model/resource throws an error: undefined method `scope_name' for #<Decidim::ParticipatoryProcessGroup
            # count: cell("decidim/participatory_process_groups/content_blocks/related_processes", model).total_count
            count: 2
          )
        }
      end

      def meta_scope_item
        return if (scope_text = translated_attribute(meta_scope)).blank?

        {
          icon: "globe-line",
          text: scope_text
        }
      end
    end
  end
end
