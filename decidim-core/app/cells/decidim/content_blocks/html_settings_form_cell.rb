# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HtmlSettingsFormCell < Decidim::ViewModel
      alias form model

      def content_block
        options[:content_block]
      end

      def label
        I18n.t("decidim.content_blocks.html.html_content")
      end
    end
  end
end
