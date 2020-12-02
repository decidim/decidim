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
        translated_attribute model.title
      end

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
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
        # rubocop: disable Style/StringConcatenation
        content_tag(
          :strong,
          t("layouts.decidim.participatory_process_groups.participatory_process_group.processes_count")
        ) + " " + processes_visible_for_user
        # rubocop: enable Style/StringConcatenation
      end

      def processes_visible_for_user
        processes = model.participatory_processes.published

        if current_user
          return processes.count.to_s if current_user.admin

          processes.visible_for(current_user).count.to_s
        else
          processes.public_spaces.count.to_s
        end
      end
    end
  end
end
