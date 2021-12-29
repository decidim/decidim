# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Small (:s) process card
    # for an given instance of a ParticipatoryProcess
    class ProcessSCell < Decidim::CardMCell
      private

      def has_image?
        model.hero_image.attached?
      end

      def has_step?
        model.active_step.present?
      end

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def step_title
        translated_attribute model.active_step.title
      end

      def i18n_scope
        "decidim.participatory_processes.pages.home.highlighted_processes"
      end
    end
  end
end
