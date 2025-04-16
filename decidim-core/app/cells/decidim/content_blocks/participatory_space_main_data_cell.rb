# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMainDataCell < BaseCell
      private

      def extra_classes
        "participatory-space__content-block"
      end

      def rich_text_processors?
        false
      end

      def title; end

      def short_description_text; end

      def description_text; end

      def nav_items
        []
      end
    end
  end
end
