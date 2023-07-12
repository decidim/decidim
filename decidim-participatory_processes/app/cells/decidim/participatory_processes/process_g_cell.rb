# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Grid (:g) process card
    # for an given instance of a Process
    class ProcessGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def start_date
        model.start_date
      end

      def end_date
        model.end_date
      end

      def metadata_cell
        "decidim/participatory_processes/process_metadata_g"
      end
    end
  end
end
