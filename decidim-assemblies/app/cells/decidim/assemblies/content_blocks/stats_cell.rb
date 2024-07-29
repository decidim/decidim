# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class StatsCell < Decidim::ContentBlocks::ParticipatorySpaceStatsCell
        private

        def stats
          @stats ||= AssemblyStatsPresenter.new(assembly: resource).collection
        end
      end
    end
  end
end
