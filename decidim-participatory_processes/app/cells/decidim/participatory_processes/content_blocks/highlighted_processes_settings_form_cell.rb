# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class HighlightedProcessesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def max_results_label
          I18n.t("decidim.participatory_processes.admin.content_blocks.highlighted_processes.max_results")
        end

        def unlimited_label
          I18n.t("decidim.participatory_processes.admin.content_blocks.highlighted_processes.unlimited")
        end
      end
    end
  end
end
