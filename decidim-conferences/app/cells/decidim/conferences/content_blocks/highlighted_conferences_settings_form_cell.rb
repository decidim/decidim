# frozen_string_literal: true

module Decidim
  module Conferences
    module ContentBlocks
      class HighlightedConferencesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.conferences.admin.content_blocks.highlighted_conferences.max_results")
        end
      end
    end
  end
end
