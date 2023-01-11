# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    class ProcessMetadataGCell < Decidim::ParticipatoryProcesses::ProcessMetadataCell
      private

      def items
        [progress_item, interactions_count].compact
      end

      def interactions_count
        # REDESIGN_PENDING
        {
          text: "2666 interactions",
          icon: "bubble-chart-line"
        }
      end
    end
  end
end
