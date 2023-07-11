# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      class MetricsCell < Decidim::ContentBlocks::ParticipatorySpaceMetricsCell
        def metrics
          nil

          # @metrics ||= VotingsMetricChartsPresenter.new(participatory_process: resource)
        end
      end
    end
  end
end
