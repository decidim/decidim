# frozen_string_literal: true

module Decidim
  module Initiatives
    module ContentBlocks
      class HighlightedInitiativesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.initiatives.admin.content_blocks.highlighted_initiatives.max_results")
        end
      end
    end
  end
end
