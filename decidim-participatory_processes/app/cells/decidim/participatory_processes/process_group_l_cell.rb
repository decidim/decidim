# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the List (:l) process group card
    # for a given instance of a ParticipatoryProcessGroup
    class ProcessGroupLCell < Decidim::CardLCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def metadata_cell
        "decidim/participatory_processes/process_group_metadata"
      end
    end
  end
end
