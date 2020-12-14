# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedElementsSettingsFormCell < Decidim::ViewModel
      alias form model

      def order_options
        available_sorts.map do |sort_key|
          [
            I18n.t("decidim.content_blocks.highlighted_elements_settings_form.orders.#{sort_key}"),
            sort_key
          ]
        end
      end

      def label
        I18n.t("decidim.content_blocks.highlighted_elements_settings_form.orders.label")
      end

      private

      def available_sorts
        %w(random recent)
      end
    end
  end
end
