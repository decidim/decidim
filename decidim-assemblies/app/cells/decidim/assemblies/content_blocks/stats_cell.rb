# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class StatsCell < Decidim::ContentBlocks::ParticipatorySpaceStatsCell
        private

        def stats
          @stats ||= resource.show_statistics && AssemblyStatsPresenter.new(assembly: resource).collection
        end
      end
    end
  end
end
