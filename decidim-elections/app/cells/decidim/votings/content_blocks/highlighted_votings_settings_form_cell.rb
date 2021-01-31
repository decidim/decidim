# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class HighlightedVotingsSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.votings.admin.content_blocks.highlighted_votings.max_results")
        end
      end
    end
  end
end
