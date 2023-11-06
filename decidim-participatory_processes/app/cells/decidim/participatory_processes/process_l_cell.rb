# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    # This cell renders the List (:l) process card
    # for an instance of a ParricipatoryProcess
    class ProcessLCell < Decidim::CardLCell
      include ApplicationHelper

      delegate :component_settings, to: :controller

      alias result model

      private

      def resource_image_path
        model.attached_uploader(:hero_image).path
      end

      def metadata_cell
        "decidim/participatory_processes/process_metadata"
      end
    end
  end
end
