# frozen_string_literal: true

module Decidim
  module Initiatives
    module ContentBlocks
      class HighlightedInitiativesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def max_results_label
          I18n.t("decidim.initiatives.admin.content_blocks.highlighted_initiatives.max_results")
        end

        def order_label
          I18n.t("decidim.initiatives.admin.content_blocks.highlighted_initiatives.order.label")
        end

        def order_select
          [
            [I18n.t("decidim.initiatives.admin.content_blocks.highlighted_initiatives.order.default"), "default"],
            [I18n.t("decidim.initiatives.admin.content_blocks.highlighted_initiatives.order.most_recent"), "most_recent"]
          ]
        end
      end
    end
  end
end
