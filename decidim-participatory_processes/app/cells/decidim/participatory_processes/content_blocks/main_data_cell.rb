# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class MainDataCell < Decidim::ContentBlocks::ParticipatorySpaceMainDataCell
        include ParticipatorySpaceContentBlocksHelper
        include ParticipatoryProcessHelper
        include Decidim::ComponentPathHelper
        include ActiveLinkTo
        include Decidim::SanitizeHelper
        include Decidim::ModalHelper

        delegate :short_description, :steps, :active_step, :start_date, :end_date, :participatory_process_group, to: :resource

        private

        def title_text
          t("title", scope: "decidim.participatory_processes.participatory_processes.show")
        end

        def description_text
          decidim_sanitize_editor translated_attribute(short_description)
        end

        def details_path
          decidim_participatory_processes.description_participatory_process_path(resource)
        end

        def nav_items
          process_nav_items(resource)
        end

        def metadata_items
          [step_metadata_item, dates_metadata_item, group_item].compact
        end

        def classes_prefix
          "process"
        end

        def active_step_name
          translated_attribute active_step.title
        end

        def step_metadata_item
          {
            title: t("active_step", scope: "layouts.decidim.participatory_processes.participatory_process"),
            icon: "direction-line",
            partial: "active_step"
          }
        end

        def dates_metadata_item
          {
            title: [
              t("start_date", scope: "activemodel.attributes.participatory_process_step"),
              t("end_date", scope: "activemodel.attributes.participatory_process_step")
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
              translated_attribute(participatory_process_group.title),
              decidim_participatory_processes.participatory_process_group_path(participatory_process_group)
            )
          }
        end

        def extra_classes
          prefixed_class("content-block")
        end
      end
    end
  end
end
