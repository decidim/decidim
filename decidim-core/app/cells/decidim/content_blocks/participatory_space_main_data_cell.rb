# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMainDataCell < BaseCell
      def nav_links
        return if nav_items.blank?

        render :nav_links
      end

      private

      def extra_classes
        "participatory-space__content-block"
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
