# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # This block uses a cell to list elements and generates a content block
    # that passes the highlighted elements configured in the content block
    class HighlightedElementsWithCellForListCell < HighlightedElementsCell
      def show
        render unless list_cell.try(:items_blank?)
      end

      private

      def list_cell_path
        raise "#{self.class.name} is expected to implement #list_cell_path"
      end

      def list_cell
        @list_cell ||= cell(
          list_cell_path,
          published_components.one? ? published_components.first : published_components,
          **model.settings.to_h.merge(see_all_path:)
        )
      end

      def see_all_path; end
    end
  end
end
