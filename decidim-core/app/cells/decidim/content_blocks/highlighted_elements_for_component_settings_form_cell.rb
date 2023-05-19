# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedElementsForComponentSettingsFormCell < HighlightedElementsSettingsFormCell
      include Decidim::ContentBlocks::HasRelatedComponents

      def component_label
        I18n.t("label", scope: translations_scope)
      end

      def component_options
        components.map { |component| [translated_attribute(component.name), component.id] }.prepend([I18n.t("all", scope: translations_scope), nil])
      end

      def include_order_setting?
        form.object.settings.attribute_names.include? "order"
      end

      private

      def components
        @components ||= components_for(options[:content_block])
      end

      def translations_scope
        "decidim.content_blocks.highlighted_elements_settings_form.components"
      end
    end
  end
end
