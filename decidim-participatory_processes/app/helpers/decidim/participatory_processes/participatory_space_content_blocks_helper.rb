# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Method shared by different content blocks for the process
    #
    module ParticipatorySpaceContentBlocksHelper
      def base_model
        Decidim::ParticipatoryProcess
      end

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end
    end
  end
end
