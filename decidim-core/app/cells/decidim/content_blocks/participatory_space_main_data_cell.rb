# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMainDataCell < BaseCell
      private

      def extra_classes
        "participatory-space__content-block"
      end

      def title; end

      def description_text; end

      def details_path; end

      def nav_items
        []
      end
    end
  end
end
