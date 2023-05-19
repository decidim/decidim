# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ContentBlocks
      class MetricsCell < Decidim::ContentBlocks::ParticipatorySpaceMetricsCell
        include ParticipatorySpaceContentBlocksHelper

        private

        def metrics
          @metrics ||= ParticipatoryProcessMetricChartsPresenter.new(participatory_process: resource)
        end

        def scope
          "participatory_process"
        end

        def show_all_path
          decidim_participatory_processes.all_metrics_participatory_process_path(resource)
        end
      end
    end
  end
end
