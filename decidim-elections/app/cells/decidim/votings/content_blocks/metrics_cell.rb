# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      # VotingsMetricChartsPresenter is not implemented yet. This cell will not
      # display anything if metrics method is blank
      class MetricsCell < Decidim::ContentBlocks::ParticipatorySpaceMetricsCell
        def metrics
          nil

          # @metrics ||= VotingsMetricChartsPresenter.new(participatory_process: resource)
        end
      end
    end
  end
end
