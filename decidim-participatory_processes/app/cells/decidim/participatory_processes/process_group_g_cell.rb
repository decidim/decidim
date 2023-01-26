# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Grid (:g) process card
    # for an given instance of a Process
    class ProcessGroupGCell < Decidim::CardGCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
      end

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end
    end
  end
end
