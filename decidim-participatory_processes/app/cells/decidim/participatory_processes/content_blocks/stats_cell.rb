# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class StatsCell < Decidim::ContentBlocks::ParticipatorySpaceStatsCell
        include ParticipatorySpaceContentBlocksHelper

        private

        def stats
          @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: resource).collection
        end
      end
    end
  end
end
