# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class HighlightedAssembliesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.assemblies.admin.content_blocks.highlighted_assemblies.max_results")
        end
      end
    end
  end
end
