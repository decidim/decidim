# frozen_string_literal: true

require "cell/partial"

module Decidim
  module ParticipatoryProcesses
    class ProcessMetadataGCell < Decidim::ParticipatoryProcesses::ProcessMetadataCell
      private

      def items
        [progress_item, active_phase_item].compact
      end
    end
  end
end
