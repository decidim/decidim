# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class HighlightedProcessGroupsSettingsFormCell < Decidim::ViewModel
        alias form model

        def order_options
          available_sorts.map do |sort_key|
            [
              I18n.t("decidim.participatory_process_groups.content_blocks.highlighted_process_groups_settings_form.orders.#{sort_key}"),
              sort_key
            ]
          end
        end

        def max_results_label
          I18n.t("decidim.participatory_process_groups.content_blocks.highlighted_process_groups_settings_form.max_results.label")
        end

        def order_label
          I18n.t("decidim.participatory_process_groups.content_blocks.highlighted_process_groups_settings_form.orders.label")
        end

        private

        def available_sorts
          %w(random recent)
        end
      end
    end
  end
end
