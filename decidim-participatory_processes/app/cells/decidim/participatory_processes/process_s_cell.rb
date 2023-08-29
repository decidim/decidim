# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Search (:s) process card
    # for a given instance of a ParticipatoryProcess
    class ProcessSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/participatory_processes/process_metadata"
      end
    end
  end
end
