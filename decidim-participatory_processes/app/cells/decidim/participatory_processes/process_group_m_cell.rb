# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Medium (:m) process group card
    # for an given instance of a ProcessGroup
    class ProcessGroupMCell < Decidim::CardMCell
      private

      def has_image?
        true
      end

      def resource_image_path
        model.hero_image.url
      end

      def title
        translated_attribute model.name
      end

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
      end

      def step_action_btn_text
        translated_attribute(model.active_step.action_btn_text) ||
        t("participatory_processes.participatory_process.take_part", scope: "layouts.decidim")
      end

      def step_title
        translated_attribute model.active_step.title
      end

      def card_classes
        ["card--process", "card--stack"].join(" ")
      end

      def statuses
        super << :processes_count
      end

      def processes_count_status
        content_tag(
          :strong,
          t("layouts.decidim.participatory_process_groups.participatory_process_group.processes_count")
        ) + " " + model.participatory_processes.count.to_s
      end
    end
  end
end
