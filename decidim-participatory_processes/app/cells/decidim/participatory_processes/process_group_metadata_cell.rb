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
            count:
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

      def count
        # REDESIGN_PENDING: Use the following call to content block when
        # available merging https://github.com/decidim/decidim/pull/10491
        # cell("decidim/participatory_process_groups/content_blocks/related_processes", nil, resource: model).total_count
        Decidim::ParticipatoryProcesses::GroupPublishedParticipatoryProcesses.new(model, current_user).query.size
      end
    end
  end
end
