# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Grid (:g) process card
    # for a given instance of a ParticipatoryProcess
    class ProcessGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_path(model, locale: I18n.locale)
      end

      def resource_image_url
        model.attached_uploader(:hero_image).url
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
