# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        include ParticipatorySpaceContentBlocksHelper

        delegate :phases, :active_phase, :start_date, :end_date, :participatory_process_group, to: :resource

        private

        def extra_data_items
          [dates_item, phase_item, group_item].compact
        end

        def active_phase_name
          translated_attribute active_phase.title
        end

        def phase_item
          return if active_phase.blank?

          {
            title: t("active_phase", scope: "layouts.decidim.participatory_processes.participatory_process"),
            icon: "direction-line",
            partial: "active_phase"
          }
        end

        def dates_item
          {
            title: [
              t("start_date", scope: "activemodel.attributes.participatory_process_phase"),
              t("end_date", scope: "activemodel.attributes.participatory_process_phase")
            ].join(" / "),
            icon: "calendar-todo-line",
            text: [
              start_date.present? ? l(start_date, format: :decidim_short_with_month_name_short) : "?",
              end_date.present? ? l(end_date, format: :decidim_short_with_month_name_short) : "?"
            ].join(" / ")
          }
        end

        def group_item
          return if participatory_process_group.blank?

          {
            title: t("belongs_to_group", scope: "decidim.participatory_processes.show"),
            icon: "archive-line",
            text: link_to(
              decidim_escape_translated(participatory_process_group.title).html_safe,
              decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
            )
          }
        end
      end
    end
  end
end
