# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class TwoPaneSectionSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label_left_column
          I18n.t("decidim.content_blocks.static_page.two_pane_section.left_column")
        end

        def label_right_column
          I18n.t("decidim.content_blocks.static_page.two_pane_section.right_column")
        end
      end
    end
  end
end
