# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class ProcessesSettingsFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def include_default_filter_setting?
          form.object.settings.attribute_names.include? "default_filter"
        end

        def default_filter_label
          I18n.t("decidim.participatory_processes.admin.content_blocks.highlighted_processes.selection_criteria")
        end

        def default_filter_options
          [[I18n.t("decidim.participatory_processes.admin.content_blocks.highlighted_processes.active"), "active"],
           [I18n.t("decidim.participatory_processes.admin.content_blocks.highlighted_processes.all"), "all"]]
        end
      end
    end
  end
end
