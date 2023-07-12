# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module StaticPage
      class SummarySettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.content_blocks.static_page.summary.summary_content")
        end
      end
    end
  end
end
