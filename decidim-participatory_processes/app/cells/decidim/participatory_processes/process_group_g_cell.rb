# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Grid (:g) process card
    # for a given instance of a ParticipatoryProcess
    class ProcessGroupGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model, locale: current_locale)
      end

      def resource_image_url
        model.attached_uploader(:hero_image).url
      end

      def metadata_cell
        "decidim/participatory_processes/process_group_metadata"
      end
    end
  end
end
