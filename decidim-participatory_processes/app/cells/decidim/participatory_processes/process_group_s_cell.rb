# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Search (:s) process group card
    # for a given instance of a ParticipatoryProcessGroup
    class ProcessGroupSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/participatory_processes/process_metadata"
      end
    end
  end
end
