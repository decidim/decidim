# frozen_string_literal: true

module Decidim
  module Votings
    module ContentBlocks
      module LandingPage
        class MetricsCell < Decidim::ViewModel
          delegate :current_participatory_space, to: :controller

          def metrics
            nil

            # @metrics ||= VotingsMetricChartsPresenter.new(participatory_process: current_participatory_space)
          end
        end
      end
    end
  end
end
