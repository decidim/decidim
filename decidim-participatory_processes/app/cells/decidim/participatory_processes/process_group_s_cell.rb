# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Search (:s) process group card
    # for a given instance of a ParticipatoryProcessGroup
    class ProcessGroupSCell < Decidim::CardSCell
      private

      def resource_path
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers.participatory_process_group_path(model)
      end

      def metadata_cell
        "decidim/participatory_processes/process_group_metadata"
      end
    end
  end
end
