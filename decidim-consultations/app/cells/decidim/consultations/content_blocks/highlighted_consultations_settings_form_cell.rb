# frozen_string_literal: true

module Decidim
  module Consultations
    module ContentBlocks
      class HighlightedConsultationsSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def label
          I18n.t("decidim.consultations.admin.content_blocks.highlighted_consultations.max_results")
        end
      end
    end
  end
end
