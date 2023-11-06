# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMetadataCell < BaseCell
      def show
        return if metadata_valued_items.blank?

        render
      end

      def metadata_valued_items
        metadata_items.filter_map do |item|
          next if (value = translated_attribute(presented_space.send(item))).blank?

          {
            title: t(item, scope: translations_scope),
            value:
          }
        end
      end

      private

      def metadata_items = []

      def presented_space
        space_presenter.new(resource)
      end

      def space_presenter
        raise "#{self.class.name} is expected to implement #space_presenter"
      end

      def translations_scope
        raise "#{self.class.name} is expected to implement #translations_scope"
      end
    end
  end
end
